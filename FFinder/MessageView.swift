import SwiftUI

struct MessageView: View {
    @Binding var message: String

    var body: some View {
        Text(message)
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .padding(.bottom)
            .foregroundColor(.primary)
    }
}
