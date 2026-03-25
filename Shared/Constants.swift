import Foundation

enum AppConstants {
    static let appGroupIdentifier = "group.com.hau.adblocker"
    static let contentBlockerBundleIdentifier = "com.hau.adblocker.ContentBlocker"
    static let assembledRulesFileName = "assembledRules.json"

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    static var assembledRulesURL: URL? {
        sharedContainerURL?.appendingPathComponent(assembledRulesFileName)
    }
}
