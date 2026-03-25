import XCTest
@testable import AdBlocker

@MainActor
final class FilterPipelineIntegrationTests: XCTestCase {

    func testFullPipelineAllCategoriesEnabled() async throws {
        let defaults = UserDefaults(suiteName: "test.pipeline.all.\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        let source = MockFilterSource.withDefaultRules()
        let engine = FilterEngine(filterSource: source, settingsStore: settings)

        let rules = try await engine.assembleRules()

        // Validate output is valid JSON array
        let data = try JSONEncoder().encode(rules)
        let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertNotNil(jsonArray)
        XCTAssertEqual(jsonArray?.count, 5) // 2 ads + 1 tracker + 1 social + 1 annoyance
    }

    func testFullPipelineWithWhitelist() async throws {
        let defaults = UserDefaults(suiteName: "test.pipeline.wl.\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        settings.addWhitelistDomain("example.com")
        settings.addWhitelistDomain("safe.org")

        let source = MockFilterSource.withDefaultRules()
        let engine = FilterEngine(filterSource: source, settingsStore: settings)

        let rules = try await engine.assembleRules()

        // Last 2 rules should be ignore-previous-rules
        let lastTwo = rules.suffix(2)
        for rule in lastTwo {
            XCTAssertEqual(rule.action.type, "ignore-previous-rules")
        }

        // Total: 5 category rules + 2 whitelist rules
        XCTAssertEqual(rules.count, 7)
    }

    func testFullPipelinePartialCategories() async throws {
        let defaults = UserDefaults(suiteName: "test.pipeline.partial.\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        settings.toggleCategory(.ads)
        settings.toggleCategory(.social)

        let source = MockFilterSource.withDefaultRules()
        let engine = FilterEngine(filterSource: source, settingsStore: settings)

        let rules = try await engine.assembleRules()

        // Only trackers (1) + annoyances (1) = 2
        XCTAssertEqual(rules.count, 2)

        // Should not contain any ad rules
        let hasAdRule = rules.contains { $0.trigger.urlFilter == "doubleclick\\.net" }
        XCTAssertFalse(hasAdRule)
    }

    func testAssembledJSONWritesToDiskAndIsReadable() async throws {
        let defaults = UserDefaults(suiteName: "test.pipeline.disk.\(UUID().uuidString)")!
        let settings = SettingsStore(defaults: defaults)
        let source = MockFilterSource.withDefaultRules()
        let engine = FilterEngine(filterSource: source, settingsStore: settings)

        let rules = try await engine.assembleRules()

        // Write to temp file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_rules_\(UUID().uuidString).json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(rules)
        try data.write(to: tempURL, options: .atomic)

        // Read back and verify
        let readData = try Data(contentsOf: tempURL)
        let decoded = try JSONDecoder().decode([FilterRule].self, from: readData)
        XCTAssertEqual(decoded.count, rules.count)
        XCTAssertEqual(decoded, rules)

        // Cleanup
        try? FileManager.default.removeItem(at: tempURL)
    }
}
