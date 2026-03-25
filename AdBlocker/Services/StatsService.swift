import Foundation

@MainActor
@Observable
final class StatsService {
    private let settingsStore: SettingsStore
    private let filterEngine: FilterEngine

    private static let estimatedBlocksPerRulePerDay: Double = 2.5

    var estimatedBlockedRequests: Int {
        let daysActive = max(1, Calendar.current.dateComponents(
            [.day],
            from: settingsStore.installDate,
            to: .now
        ).day ?? 1)

        return Int(
            Double(filterEngine.activeRuleCount)
            * Self.estimatedBlocksPerRulePerDay
            * Double(daysActive)
        )
    }

    var activeRuleCount: Int {
        filterEngine.activeRuleCount
    }

    init(settingsStore: SettingsStore, filterEngine: FilterEngine) {
        self.settingsStore = settingsStore
        self.filterEngine = filterEngine
    }
}
