import Foundation

@MainActor
@Observable
final class FilterEngine {
    private let filterSource: FilterSourceProviding
    private let contentBlockerManager: ContentBlockerManager
    private let settingsStore: SettingsStore

    private(set) var activeRuleCount: Int = 0
    private(set) var isReloading: Bool = false
    private(set) var lastError: String?
    private(set) var extensionEnabled: Bool = true

    init(
        filterSource: FilterSourceProviding = BundledFilterSource(),
        contentBlockerManager: ContentBlockerManager = ContentBlockerManager(),
        settingsStore: SettingsStore
    ) {
        self.filterSource = filterSource
        self.contentBlockerManager = contentBlockerManager
        self.settingsStore = settingsStore
    }

    func assembleAndReload() async {
        isReloading = true
        lastError = nil

        do {
            let rules = try await assembleRules()
            try writeRulesToSharedContainer(rules)
            activeRuleCount = rules.count

            do {
                try await contentBlockerManager.reloadContentBlocker()
                extensionEnabled = true
            } catch let error as NSError where error.domain == "SFErrorDomain" && error.code == 1 {
                // Extension not enabled in Safari Settings yet - not a real error
                extensionEnabled = false
            }
        } catch {
            lastError = error.localizedDescription
        }

        isReloading = false
    }

    func assembleRules() async throws -> [FilterRule] {
        var allRules: [FilterRule] = []

        for category in filterSource.allCategories() {
            guard settingsStore.isCategoryEnabled(category) else { continue }
            let rules = try await filterSource.rules(for: category)
            allRules.append(contentsOf: rules)
        }

        let whitelistRules = settingsStore.whitelistedDomains.map { entry in
            FilterRule(
                trigger: FilterRule.Trigger(
                    urlFilter: ".*",
                    ifDomain: ["*\(entry.domain)"]
                ),
                action: FilterRule.Action(type: "ignore-previous-rules")
            )
        }
        allRules.append(contentsOf: whitelistRules)

        return allRules
    }

    private func writeRulesToSharedContainer(_ rules: [FilterRule]) throws {
        guard let url = AppConstants.assembledRulesURL else {
            throw FilterEngineError.sharedContainerUnavailable
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(rules)
        try data.write(to: url, options: .atomic)
    }
}

enum FilterEngineError: LocalizedError, Sendable {
    case sharedContainerUnavailable

    var errorDescription: String? {
        switch self {
        case .sharedContainerUnavailable:
            "App Group shared container is not available"
        }
    }
}
