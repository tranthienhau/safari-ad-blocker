import XCTest
@testable import AdBlocker

final class BundledFilterSourceTests: XCTestCase {
    private var source: BundledFilterSource!

    override func setUp() {
        super.setUp()
        source = BundledFilterSource()
    }

    func testAllCategoriesReturnsAllFour() {
        let categories = source.allCategories()
        XCTAssertEqual(categories.count, 4)
        XCTAssertEqual(Set(categories), Set(FilterCategory.allCases))
    }

    func testLoadAdsRules() async throws {
        let rules = try await source.rules(for: .ads)
        XCTAssertFalse(rules.isEmpty, "Ads rules should not be empty")
        XCTAssertGreaterThanOrEqual(rules.count, 20, "Should have at least 20 ad rules")
    }

    func testLoadTrackersRules() async throws {
        let rules = try await source.rules(for: .trackers)
        XCTAssertFalse(rules.isEmpty, "Tracker rules should not be empty")
        XCTAssertGreaterThanOrEqual(rules.count, 10, "Should have at least 10 tracker rules")
    }

    func testLoadSocialRules() async throws {
        let rules = try await source.rules(for: .social)
        XCTAssertFalse(rules.isEmpty, "Social rules should not be empty")
        XCTAssertGreaterThanOrEqual(rules.count, 8, "Should have at least 8 social rules")
    }

    func testLoadAnnoyancesRules() async throws {
        let rules = try await source.rules(for: .annoyances)
        XCTAssertFalse(rules.isEmpty, "Annoyances rules should not be empty")
        XCTAssertGreaterThanOrEqual(rules.count, 8, "Should have at least 8 annoyance rules")
    }

    func testEveryRuleHasNonEmptyUrlFilter() async throws {
        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                XCTAssertFalse(
                    rule.trigger.urlFilter.isEmpty,
                    "Rule \(index) in \(category) has empty url-filter"
                )
            }
        }
    }

    func testEveryRuleActionTypeIsValid() async throws {
        let validTypes: Set<String> = ["block", "css-display-none", "ignore-previous-rules"]

        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                XCTAssertTrue(
                    validTypes.contains(rule.action.type),
                    "Rule \(index) in \(category) has invalid action type: \(rule.action.type)"
                )
            }
        }
    }

    func testCssDisplayNoneRulesHaveSelector() async throws {
        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                if rule.action.type == "css-display-none" {
                    XCTAssertNotNil(
                        rule.action.selector,
                        "css-display-none rule \(index) in \(category) must have a selector"
                    )
                    XCTAssertFalse(
                        rule.action.selector!.isEmpty,
                        "css-display-none rule \(index) in \(category) has empty selector"
                    )
                }
            }
        }
    }
}
