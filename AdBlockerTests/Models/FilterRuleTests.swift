import XCTest
@testable import AdBlocker

final class FilterRuleTests: XCTestCase {

    func testDecodeValidSafariJSON() throws {
        let json = """
        {
            "trigger": {
                "url-filter": "doubleclick\\\\.net",
                "resource-type": ["script", "image"],
                "load-type": ["third-party"]
            },
            "action": {
                "type": "block"
            }
        }
        """.data(using: .utf8)!

        let rule = try JSONDecoder().decode(FilterRule.self, from: json)

        XCTAssertEqual(rule.trigger.urlFilter, "doubleclick\\.net")
        XCTAssertEqual(rule.trigger.resourceType, ["script", "image"])
        XCTAssertEqual(rule.trigger.loadType, ["third-party"])
        XCTAssertEqual(rule.action.type, "block")
    }

    func testDecodeRuleWithSelector() throws {
        let json = """
        {
            "trigger": { "url-filter": ".*" },
            "action": { "type": "css-display-none", "selector": ".cookie-banner" }
        }
        """.data(using: .utf8)!

        let rule = try JSONDecoder().decode(FilterRule.self, from: json)

        XCTAssertEqual(rule.action.type, "css-display-none")
        XCTAssertEqual(rule.action.selector, ".cookie-banner")
    }

    func testDecodeRuleWithDomainFilters() throws {
        let json = """
        {
            "trigger": {
                "url-filter": ".*",
                "if-domain": ["*example.com"],
                "unless-domain": ["*safe.example.com"]
            },
            "action": { "type": "block" }
        }
        """.data(using: .utf8)!

        let rule = try JSONDecoder().decode(FilterRule.self, from: json)

        XCTAssertEqual(rule.trigger.ifDomain, ["*example.com"])
        XCTAssertEqual(rule.trigger.unlessDomain, ["*safe.example.com"])
    }

    func testEncodeBackToMatchingJSON() throws {
        let rule = FilterRule(
            trigger: FilterRule.Trigger(
                urlFilter: "adnxs\\.com",
                resourceType: ["script"],
                loadType: ["third-party"]
            ),
            action: FilterRule.Action(type: "block")
        )

        let data = try JSONEncoder().encode(rule)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let trigger = dict["trigger"] as! [String: Any]
        XCTAssertEqual(trigger["url-filter"] as? String, "adnxs\\.com")
        XCTAssertEqual(trigger["resource-type"] as? [String], ["script"])
        XCTAssertEqual(trigger["load-type"] as? [String], ["third-party"])
    }

    func testCodingKeysMapToHyphenatedKeys() throws {
        let rule = FilterRule(
            trigger: FilterRule.Trigger(
                urlFilter: "test",
                urlFilterIsCaseSensitive: true,
                resourceType: ["script"],
                loadType: ["third-party"],
                ifDomain: ["*example.com"],
                unlessDomain: ["*safe.com"]
            ),
            action: FilterRule.Action(type: "block")
        )

        let data = try JSONEncoder().encode(rule)
        let jsonString = String(data: data, encoding: .utf8)!

        XCTAssertTrue(jsonString.contains("url-filter"))
        XCTAssertTrue(jsonString.contains("url-filter-is-case-sensitive"))
        XCTAssertTrue(jsonString.contains("resource-type"))
        XCTAssertTrue(jsonString.contains("load-type"))
        XCTAssertTrue(jsonString.contains("if-domain"))
        XCTAssertTrue(jsonString.contains("unless-domain"))
    }

    func testHandlesOptionalFields() throws {
        let json = """
        {
            "trigger": { "url-filter": "example\\\\.com" },
            "action": { "type": "block" }
        }
        """.data(using: .utf8)!

        let rule = try JSONDecoder().decode(FilterRule.self, from: json)

        XCTAssertNil(rule.trigger.resourceType)
        XCTAssertNil(rule.trigger.loadType)
        XCTAssertNil(rule.trigger.ifDomain)
        XCTAssertNil(rule.trigger.unlessDomain)
        XCTAssertNil(rule.action.selector)
    }

    func testEquatable() {
        let rule1 = FilterRule(
            trigger: FilterRule.Trigger(urlFilter: "test"),
            action: FilterRule.Action(type: "block")
        )
        let rule2 = FilterRule(
            trigger: FilterRule.Trigger(urlFilter: "test"),
            action: FilterRule.Action(type: "block")
        )
        let rule3 = FilterRule(
            trigger: FilterRule.Trigger(urlFilter: "other"),
            action: FilterRule.Action(type: "block")
        )

        XCTAssertEqual(rule1, rule2)
        XCTAssertNotEqual(rule1, rule3)
    }
}
