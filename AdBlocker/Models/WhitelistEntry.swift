import Foundation

struct WhitelistEntry: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let domain: String
    let dateAdded: Date

    init(id: UUID = UUID(), domain: String, dateAdded: Date = .now) {
        self.id = id
        self.domain = domain
        self.dateAdded = dateAdded
    }
}
