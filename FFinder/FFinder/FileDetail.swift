import Foundation

struct FileDetail: Identifiable {
    let id = UUID() // Unique identifier
    let name: String
    let size: Int64
    let modificationDate: Date
    let path: String
    let hash: String

    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var formattedModificationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: modificationDate)
    }
}
