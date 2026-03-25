import XCTest
@testable import AdBlocker

final class FilterCategoryTests: XCTestCase {

    func testAllCasesIterable() {
        let allCases = FilterCategory.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.ads))
        XCTAssertTrue(allCases.contains(.trackers))
        XCTAssertTrue(allCases.contains(.social))
        XCTAssertTrue(allCases.contains(.annoyances))
    }

    func testDisplayNamesNonEmpty() {
        for category in FilterCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty, "\(category) has empty display name")
        }
    }

    func testDescriptionsNonEmpty() {
        for category in FilterCategory.allCases {
            XCTAssertFalse(category.description.isEmpty, "\(category) has empty description")
        }
    }

    func testIconNamesNonEmpty() {
        for category in FilterCategory.allCases {
            XCTAssertFalse(category.iconName.isEmpty, "\(category) has empty icon name")
        }
    }

    func testRuleFileNames() {
        XCTAssertEqual(FilterCategory.ads.ruleFileName, "ads_rules")
        XCTAssertEqual(FilterCategory.trackers.ruleFileName, "trackers_rules")
        XCTAssertEqual(FilterCategory.social.ruleFileName, "social_rules")
        XCTAssertEqual(FilterCategory.annoyances.ruleFileName, "annoyances_rules")
    }

    func testRuleFileNameFormat() {
        for category in FilterCategory.allCases {
            XCTAssertTrue(
                category.ruleFileName.hasSuffix("_rules"),
                "\(category) rule file name should end with '_rules'"
            )
        }
    }

    func testCodableRoundTrip() throws {
        for category in FilterCategory.allCases {
            let data = try JSONEncoder().encode(category)
            let decoded = try JSONDecoder().decode(FilterCategory.self, from: data)
            XCTAssertEqual(category, decoded)
        }
    }

    func testIdentifiable() {
        for category in FilterCategory.allCases {
            XCTAssertEqual(category.id, category.rawValue)
        }
    }
}
