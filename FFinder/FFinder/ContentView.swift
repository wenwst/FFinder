import SwiftUI
import AppKit

struct ContentView: View {
    @State private var message: String = "Drag a file here to start searching."
    @State private var searchResults: [FileDetail] = []
    @State private var isDragging: Bool = false

    var body: some View {
        VStack(spacing: 0) {
//            CustomTitleBar()
            VStack {
                headerView
                messageView
                fileList
                Spacer()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .clipShape(BottomRoundedCorner(radius: 24))
            .overlay(
                DragDropView(message: $message, searchResults: $searchResults, isDragging: $isDragging)
                    .background(isDragging ? Color.gray.opacity(0.4) : Color.clear)
            )
            .animation(.easeInOut, value: isDragging)
            .padding(1)
        }
        .frame(minWidth: 800, minHeight: 600)
    }

    private var headerView: some View {
        Text("File Search")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .padding()
            .foregroundColor(.primary)
    }

    private var messageView: some View {
        Text(message)
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .padding(.bottom)
            .foregroundColor(.primary)
    }

    private var fileList: some View {
        Group {
            if searchResults.isEmpty {
                Text("No identical files found")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(searchResults) { file in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(nsImage: getFileIcon(for: file.path))
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 8)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(file.name)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                    Spacer()
                                    Text(file.formattedSize)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                    Text(file.formattedModificationDate)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                }
                                Text(file.path)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .lineLimit(nil)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 4)
                            
                            Button(action: {
                                openInFinder(filePath: file.path)
                            }) {
                                Image(systemName: "folder")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.primary.opacity(0.3), width: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func getFileIcon(for path: String) -> NSImage {
        let fileURL = URL(fileURLWithPath: path)
        return NSWorkspace.shared.icon(forFile: fileURL.path)
    }

    private func openInFinder(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
}


struct BottomRoundedCorner: Shape {
    var radius: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            let width = rect.size.width
            let height = rect.size.height
            
            // Start at top-left corner
            path.move(to: CGPoint(x: 0, y: 0))
            
            // Draw top and right sides
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height - radius))
            
            // Draw bottom-right corner
            path.addArc(center: CGPoint(x: width - radius, y: height - radius),
                        radius: radius,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 90),
                        clockwise: false)
            
            // Draw bottom and left sides
            path.addLine(to: CGPoint(x: radius, y: height))
            
            // Draw bottom-left corner
            path.addArc(center: CGPoint(x: radius, y: height - radius),
                        radius: radius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 180),
                        clockwise: false)
            
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        return path
    }
}



struct CustomTitleBar: View {
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .frame(height: 28)
            HStack {
                Spacer()
            }
        }
    }
}
