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
            VStack(alignment: .leading, spacing: 0) {
                if isSearching {
                    Text("Searching...").font(.headline).padding()
                }
                
                ForEach(paginatedResults) { file in
                    FileRowView(file: file)
                }
            }
        }
        .frame(maxWidth: .infinity )
    }
}

struct FileRowView: View {
    var file: FileDetail

    var body: some View {
        HStack {
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.path))
                .resizable()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading) {
                HStack {
                    Text(file.name)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    Text(file.formattedSize)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                    Text(file.formattedModificationDate)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                    Spacer()
                }
                Text(file.path)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.leading)
                Spacer()
            }
            Button(action: {
                let fileURL = URL(fileURLWithPath: file.path)
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            }) {
                Image(systemName: "link")
                    .font(.title2)
                    .scaledToFit()
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 48, height: 48)
        }
        .padding(4)
        .overlay(
            Rectangle().frame(width: nil, height: 1, alignment: .top)
                .foregroundColor(Color.gray), alignment: .top)
        .overlay(
            Rectangle().frame(width: nil, height: 1, alignment: .bottom)
                .foregroundColor(Color.gray), alignment: .bottom)
    }
}
