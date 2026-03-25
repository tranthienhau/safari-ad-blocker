import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

final class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let attachment: NSItemProvider

        if let assembledURL = AppConstants.assembledRulesURL,
           FileManager.default.fileExists(atPath: assembledURL.path) {
            attachment = NSItemProvider(contentsOf: assembledURL)!
        } else if let fallbackURL = Bundle.main.url(forResource: "blockerList", withExtension: "json") {
            attachment = NSItemProvider(contentsOf: fallbackURL)!
        } else {
            context.cancelRequest(withError: NSError(
                domain: "ContentBlocker",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No blocker list available"]
            ))
            return
        }

        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item])
    }
}
