import SwiftUI

struct PaginationView: View {
    @Binding var currentPage: Int
    var totalPages: Int

    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                if currentPage > 0 {
                    currentPage -= 1
                    print("Previous button pressed, currentPage: \(currentPage)") // Log for "Previous" button
                }
            }) {
                Text("Previous")
            }
            .disabled(currentPage == 0) // Disable button when on the first page
            .padding()
            
            Text("Page \(currentPage + 1) of \(totalPages)")
                .padding()
            
            Button(action: {
                if currentPage < totalPages - 1 {
                    currentPage += 1
                    print("Next button pressed, currentPage: \(currentPage)") // Log for "Next" button
                } else {
                    print("Next button pressed but already on the last page.")
                }
            }) {
                Text("Next")
            }
            .disabled(currentPage >= totalPages - 1) // Disable button when on the last page
            .padding()
            
            Spacer()
        }
    }
}
