import SwiftUI

struct FileListView: View {
    var searchResults: [FileDetail]
    @Binding var currentPage: Int
    var itemsPerPage: Int
    var isSearching: Bool // Add this property

    private var paginatedResults: [FileDetail] {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, searchResults.count)
        return Array(searchResults[startIndex..<endIndex])
    }

    var body: some View {
        ScrollView { // Add ScrollView to support scrolling
            VStack(alignment: .leading) {
                if isSearching {
                    Text("Searching...").font(.headline).padding()
                }
                
                ForEach(paginatedResults) { file in
                    FileRowView(file: file)
                }
            }
            .padding()
        }
    }
}

struct FileRowView: View {
    var file: FileDetail

    var body: some View {
        HStack {
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.path))
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
                // Open file in Finder
                let fileURL = URL(fileURLWithPath: file.path)
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
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
