import SwiftUI
import AppKit

struct DragDropView: NSViewRepresentable {
    @Binding var message: String
    @Binding var searchResults: [FileDetail]
    @Binding var isDragging: Bool
    @Binding var isSearching: Bool
    @Binding var searchDuration: String

    class DragDropNSView: NSView {
        var parent: DragDropView
        var currentQuery: NSMetadataQuery?
        var notificationObserver: NSObjectProtocol?
        var updateObserver: NSObjectProtocol?
        var searchStartTime: Date?
        var timer: Timer?

        init(parent: DragDropView) {
            self.parent = parent
            super.init(frame: .zero)
            self.registerForDraggedTypes([.fileURL])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            DispatchQueue.main.async {
                self.parent.isDragging = true
            }
            return .copy
        }

        override func draggingExited(_ sender: NSDraggingInfo?) {
            DispatchQueue.main.async {
                self.parent.isDragging = false
            }
        }

        override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard let fileURL = sender.draggingPasteboard.fileURLs?.first else {
                DispatchQueue.main.async {
                    self.parent.isDragging = false
                }
                return false
            }

            DispatchQueue.main.async {
                self.parent.isDragging = false
                self.startSpotlightQuery(for: fileURL)
            }
            return true
        }

        private func startSpotlightQuery(for fileURL: URL) {
            // Cancel previous query if any
            currentQuery?.stop()
            if let notificationObserver = notificationObserver {
                NotificationCenter.default.removeObserver(notificationObserver)
            }
            if let updateObserver = updateObserver {
                NotificationCenter.default.removeObserver(updateObserver)
            }

            // Clear previous search results and start timer
            DispatchQueue.main.async {
                self.parent.searchResults.removeAll()
                self.parent.message = "Searching..."
                self.parent.isSearching = true
                self.searchStartTime = Date()
                self.startTimer()
            }

            // Create new query
            let query = NSMetadataQuery()
            currentQuery = query
            query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, fileURL.lastPathComponent)
            query.searchScopes = [NSMetadataQueryLocalComputerScope]

            notificationObserver = NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: query, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                self.processResults(query.results as! [NSMetadataItem])
                query.stop()
            }

            updateObserver = NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidUpdate, object: query, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                self.processResults(query.results as! [NSMetadataItem])
            }

            query.start()
        }

        private func processResults(_ results: [NSMetadataItem]) {
            let filePaths = results.compactMap { $0.value(forAttribute: NSMetadataItemPathKey) as? String }
            for path in filePaths {
                DispatchQueue.global(qos: .background).async {
                    if let detail = self.fileDetail(from: path) {
                        DispatchQueue.main.async {
                            self.parent.searchResults.append(detail)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                if self.parent.searchResults.isEmpty {
                    self.parent.message = "File not found"
                } else {
                    self.parent.message = "Files found:"
                }
                self.stopTimer()
                self.parent.isSearching = false
            }
        }

        private func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self, let startTime = self.searchStartTime else { return }
                let elapsed = Date().timeIntervalSince(startTime)
                let minutes = Int(elapsed) / 60
                let seconds = Int(elapsed) % 60
                DispatchQueue.main.async {
                    self.parent.searchDuration = String(format: "Elapsed time: %02d:%02d", minutes, seconds)
                }
            }
        }

        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

        private func fileDetail(from path: String) -> FileDetail? {
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
                return nil
            }
            let fileSize = (attributes[.size] as? NSNumber)?.int64Value ?? 0
            let modificationDate = (attributes[.modificationDate] as? Date) ?? Date()
            let fileHash = Utils.computeFileHash(for: path)
            return FileDetail(
                name: URL(fileURLWithPath: path).lastPathComponent,
                size: fileSize,
                modificationDate: modificationDate,
                path: path,
                hash: fileHash ?? "unknown"
            )
        }
    }

    func makeNSView(context: Context) -> NSView {
        return DragDropNSView(parent: self)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension NSPasteboard.PasteboardType {
    static let fileURL = NSPasteboard.PasteboardType(kUTTypeFileURL as String)
}

extension NSPasteboard {
    var fileURLs: [URL]? {
        return pasteboardItems?.compactMap { $0.fileURL }
    }
}

extension NSPasteboardItem {
    var fileURL: URL? {
        guard let urlString = string(forType: .fileURL), let url = URL(string: urlString) else { return nil }
        return url
    }
}
