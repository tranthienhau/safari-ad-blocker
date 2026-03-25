import Foundation

@MainActor
@Observable
final class SettingsStore {
    private let defaults: UserDefaults

    private enum Keys {
        static let enabledCategories = "enabledCategories"
        static let whitelistedDomains = "whitelistedDomains"
        static let onboardingCompleted = "onboardingCompleted"
        static let installDate = "installDate"
    }

    var onboardingCompleted: Bool {
        didSet { defaults.set(onboardingCompleted, forKey: Keys.onboardingCompleted) }
    }

    private(set) var enabledCategories: Set<String> {
        didSet { saveEnabledCategories() }
    }

    private(set) var whitelistedDomains: [WhitelistEntry] {
        didSet { saveWhitelistedDomains() }
    }

    let installDate: Date

    init(defaults: UserDefaults? = nil) {
        let store = defaults ?? UserDefaults(suiteName: AppConstants.appGroupIdentifier) ?? .standard
        self.defaults = store

        self.onboardingCompleted = store.bool(forKey: Keys.onboardingCompleted)

        if let savedCategories = store.stringArray(forKey: Keys.enabledCategories) {
            self.enabledCategories = Set(savedCategories)
        } else {
            self.enabledCategories = Set(FilterCategory.allCases.map(\.rawValue))
        }

        if let data = store.data(forKey: Keys.whitelistedDomains),
           let entries = try? JSONDecoder().decode([WhitelistEntry].self, from: data) {
            self.whitelistedDomains = entries
        } else {
            self.whitelistedDomains = []
        }

        if let saved = store.object(forKey: Keys.installDate) as? Date {
            self.installDate = saved
        } else {
            let now = Date.now
            store.set(now, forKey: Keys.installDate)
            self.installDate = now
        }
    }

    func isCategoryEnabled(_ category: FilterCategory) -> Bool {
        enabledCategories.contains(category.rawValue)
    }

    func toggleCategory(_ category: FilterCategory) {
        if enabledCategories.contains(category.rawValue) {
            enabledCategories.remove(category.rawValue)
        } else {
            enabledCategories.insert(category.rawValue)
        }
    }

    func addWhitelistDomain(_ domain: String) {
        let trimmed = domain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return }
        guard !whitelistedDomains.contains(where: { $0.domain == trimmed }) else { return }
        whitelistedDomains.append(WhitelistEntry(domain: trimmed))
    }

    func removeWhitelistDomain(_ entry: WhitelistEntry) {
        whitelistedDomains.removeAll { $0.id == entry.id }
    }

    private func saveEnabledCategories() {
        defaults.set(Array(enabledCategories), forKey: Keys.enabledCategories)
    }

    private func saveWhitelistedDomains() {
        if let data = try? JSONEncoder().encode(whitelistedDomains) {
            defaults.set(data, forKey: Keys.whitelistedDomains)
        }
    }
}
