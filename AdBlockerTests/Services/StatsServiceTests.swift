import XCTest
@testable import AdBlocker

@MainActor
final class StatsServiceTests: XCTestCase {

    func testZeroActiveRulesProducesZeroBlocks() {
        let defaults = UserDefaults(suiteName: "test.stats.zero.\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        let engine = FilterEngine(
            filterSource: MockFilterSource(),
            settingsStore: settings
        )
        let stats = StatsService(settingsStore: settings, filterEngine: engine)

        XCTAssertEqual(stats.estimatedBlockedRequests, 0)
    }

    func testActiveRuleCountMatchesEngine() async {
        let defaults = UserDefaults(suiteName: "test.stats.active.\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        let mockSource = MockFilterSource.withDefaultRules()
        let engine = FilterEngine(
            filterSource: mockSource,
            settingsStore: settings
        )
        let stats = StatsService(settingsStore: settings, filterEngine: engine)

        XCTAssertEqual(stats.activeRuleCount, engine.activeRuleCount)
    }
}
