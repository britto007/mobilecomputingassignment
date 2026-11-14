import Foundation
import FirebaseFirestore

/// Represents a user-owned todo task persisted in Cloud Firestore.
struct TodoTask: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date

    init(
        id: String? = nil,
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

