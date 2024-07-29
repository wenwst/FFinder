import SwiftUI
import AppKit


struct DragDropView: NSViewRepresentable {
    @Binding var message: String
    @Binding var searchResults: [FileDetail]
    @Binding var isDragging: Bool

    class DragDropNSView: NSView {
        var parent: DragDropView

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
            startSpotlightQuery(for: fileURL)
            return true
        }

        private func startSpotlightQuery(for fileURL: URL) {
            let query = NSMetadataQuery()
            query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, fileURL.lastPathComponent)
            query.searchScopes = [NSMetadataQueryLocalComputerScope]

            let notificationObserver = NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: query, queue: .main) { [weak self] notification in
                guard let self = self else { return }

                let results = query.results as! [NSMetadataItem]
                let filePaths = results.compactMap { $0.value(forAttribute: NSMetadataItemPathKey) as? String }

                DispatchQueue.main.async {
                    if filePaths.isEmpty {
                        self.parent.message = "File not found"
                    } else {
                        self.parent.message = "Files found:"
                        self.parent.searchResults = filePaths.compactMap { path in
                            self.fileDetail(from: path)
                        }
                    }
                }

                query.stop()
                // NotificationCenter.default.removeObserver(notificationObserver)
            }

            query.start()
            // Optionally remove the observer later if necessary
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
