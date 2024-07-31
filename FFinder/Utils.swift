import Foundation
import AppKit
import CommonCrypto

struct Utils {
    
    // Formats a Date into a human-readable string
    static func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Formats an Int64 size in bytes into a human-readable string
    static func formattedSize(from bytes: Int64) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useMB, .useGB, .useKB, .useBytes]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: bytes)
    }
    
    static func computeFileHash(for filePath: String) -> String? {
         let fileURL = URL(fileURLWithPath: filePath)
         guard let fileData = try? Data(contentsOf: fileURL) else { return nil }
         var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
         fileData.withUnsafeBytes {
             _ = CC_SHA256($0.baseAddress, CC_LONG(fileData.count), &hash)
         }
         return hash.map { String(format: "%02x", $0) }.joined()
     }
    
    
    static func getFileIcon(for path: String) -> NSImage {
        let fileURL = URL(fileURLWithPath: path)
        return NSWorkspace.shared.icon(forFile: fileURL.path)
    }
    
    static func openInFinder(filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
}
