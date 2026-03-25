import Foundation

enum FilterCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case ads
    case trackers
    case social
    case annoyances

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ads: "Ads"
        case .trackers: "Trackers"
        case .social: "Social Widgets"
        case .annoyances: "Annoyances"
        }
    }

    var description: String {
        switch self {
        case .ads: "Block advertisements and ad networks"
        case .trackers: "Block analytics and tracking scripts"
        case .social: "Block social media widgets and share buttons"
        case .annoyances: "Block cookie banners and newsletter popups"
        }
    }

    var iconName: String {
        switch self {
        case .ads: "nosign"
        case .trackers: "eye.slash"
        case .social: "person.2.slash"
        case .annoyances: "xmark.seal"
        }
    }

    var ruleFileName: String {
        "\(rawValue)_rules"
    }
}
