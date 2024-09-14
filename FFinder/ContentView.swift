import SwiftUI
import AppKit

struct ContentView: View {
    @State private var message: String = "Drag a file here to start searching."
    @State private var searchResults: [FileDetail] = []
    @State private var isDragging: Bool = false
    @State private var isSearching: Bool = false
    @State private var currentPage: Int = 0
    @State private var itemsPerPage: Int = 10
    @State private var searchDuration: String = "" // State for search duration
    

    private var totalPages: Int {
        (searchResults.count + itemsPerPage - 1) / itemsPerPage
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
//                MessageView(message: $message)
                FileListView(searchResults: searchResults, 
                             currentPage: $currentPage,
                             itemsPerPage: itemsPerPage,
                             isSearching: isSearching)
                    .frame(maxHeight: .infinity)
                Spacer()
            }
            .padding()
            .clipShape(BottomRoundedCorner(radius: 24))

            DragDropView(message: $message,
                         searchResults: $searchResults,
                         isDragging: $isDragging,
                         isSearching: $isSearching,
                         searchDuration: $searchDuration)
                .background(isDragging ? Color.gray.opacity(0.4) : Color.clear)
                .allowsHitTesting(false) // Allow clicks to pass through
        }
        .animation(.easeInOut, value: isDragging)
        .frame(minWidth: 800, minHeight: 600)
        .containerRelativeFrame([.horizontal, .vertical])
//        .background(Gradient(colors: [.gray, .cyan, .black])).opacity(0.6)
    }
}
