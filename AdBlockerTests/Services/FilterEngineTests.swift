import XCTest
@testable import AdBlocker

@MainActor
final class FilterEngineTests: XCTestCase {
    private var mockSource: MockFilterSource!
    private var settingsStore: SettingsStore!
    private var engine: FilterEngine!

    override func setUp() async throws {
        mockSource = MockFilterSource.withDefaultRules()
        settingsStore = SettingsStore(defaults: UserDefaults(suiteName: "test.filter.engine.\(UUID().uuidString)"))
        engine = FilterEngine(
            filterSource: mockSource,
            settingsStore: settingsStore
        )
    }

    func testAssemblesRulesOnlyForEnabledCategories() async throws {
        // Disable ads
        settingsStore.toggleCategory(.ads)

        let rules = try await engine.assembleRules()

        // Should not contain ad rules
        let hasAdRule = rules.contains { $0.trigger.urlFilter == "doubleclick\\.net" }
        XCTAssertFalse(hasAdRule, "Should not include ad rules when ads category is disabled")

        // Should still contain tracker rules
        let hasTrackerRule = rules.contains { $0.trigger.urlFilter == "google-analytics\\.com" }
        XCTAssertTrue(hasTrackerRule, "Should include tracker rules when trackers category is enabled")
    }

    func testWhitelistedDomainsProduceIgnorePreviousRules() async throws {
        settingsStore.addWhitelistDomain("example.com")
        settingsStore.addWhitelistDomain("test.org")

        let rules = try await engine.assembleRules()

        let ignoreRules = rules.filter { $0.action.type == "ignore-previous-rules" }
        XCTAssertEqual(ignoreRules.count, 2)

        let domains = ignoreRules.compactMap { $0.trigger.ifDomain?.first }
        XCTAssertTrue(domains.contains("*example.com"))
        XCTAssertTrue(domains.contains("*test.org"))
    }

    func testWhitelistRulesAppendedAtEnd() async throws {
        settingsStore.addWhitelistDomain("example.com")

        let rules = try await engine.assembleRules()

        guard let lastRule = rules.last else {
            XCTFail("Rules should not be empty")
            return
        }
        XCTAssertEqual(lastRule.action.type, "ignore-previous-rules")
    }

    func testEmptyWhitelistProducesNoIgnoreRules() async throws {
        let rules = try await engine.assembleRules()

        let ignoreRules = rules.filter { $0.action.type == "ignore-previous-rules" }
        XCTAssertEqual(ignoreRules.count, 0)
    }

    func testAllCategoriesDisabledProducesEmptyRuleSet() async throws {
        for category in FilterCategory.allCases {
            settingsStore.toggleCategory(category)
        }

        let rules = try await engine.assembleRules()
        XCTAssertTrue(rules.isEmpty, "All categories disabled should produce empty rules")
    }

    func testOutputIsValidSafariContentBlockerFormat() async throws {
        let rules = try await engine.assembleRules()

        let encoder = JSONEncoder()
        let data = try encoder.encode(rules)

        // Should be a valid JSON array
        let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertNotNil(jsonArray, "Output should be a JSON array of objects")

        // Each object should have trigger and action
        for (index, obj) in (jsonArray ?? []).enumerated() {
            XCTAssertNotNil(obj["trigger"], "Rule \(index) missing trigger")
            XCTAssertNotNil(obj["action"], "Rule \(index) missing action")

            let trigger = obj["trigger"] as? [String: Any]
            XCTAssertNotNil(trigger?["url-filter"], "Rule \(index) trigger missing url-filter")

            let action = obj["action"] as? [String: Any]
            XCTAssertNotNil(action?["type"], "Rule \(index) action missing type")
        }
    }

    func testAllCategoriesEnabledIncludesAllRules() async throws {
        let rules = try await engine.assembleRules()

        // 2 ads + 1 tracker + 1 social + 1 annoyance = 5
        XCTAssertEqual(rules.count, 5)
    }
}
