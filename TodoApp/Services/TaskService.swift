import Foundation
import FirebaseFirestore

/// Errors raised by task persistence operations.
enum TaskServiceError: LocalizedError {
    case missingTaskID

    var errorDescription: String? {
        switch self {
        case .missingTaskID:
            return "The task is missing a Firestore document identifier."
        }
    }
}

/// Abstraction over task CRUD and real-time observation for testability.
protocol TaskServicing {
    /// Starts observing tasks for `userId` and returns a cancellation closure.
    func observeTasks(
        userId: String,
        onChange: @escaping ([TodoTask]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> () -> Void

    /// Persists a new task for `userId`.
    func createTask(_ task: TodoTask, userId: String) async throws

    /// Updates an existing task for `userId`.
    func updateTask(_ task: TodoTask, userId: String) async throws

    /// Deletes a task by its document identifier for `userId`.
    func deleteTask(id: String, userId: String) async throws
}

/// Cloud Firestore implementation of `TaskServicing` scoped to `users/{userId}/tasks`.
final class FirestoreTaskService: TaskServicing {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    private func tasksCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("tasks")
    }

    func observeTasks(
        userId: String,
        onChange: @escaping ([TodoTask]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> () -> Void {
        let registration = tasksCollection(for: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onError(error)
                    return
                }
                guard let documents = snapshot?.documents else {
                    onChange([])
                    return
                }
                let tasks = documents.compactMap { try? $0.data(as: TodoTask.self) }
                onChange(tasks)
            }

        return {
            registration.remove()
        }
    }

    func createTask(_ task: TodoTask, userId: String) async throws {
        try tasksCollection(for: userId).addDocument(from: task)
    }

    func updateTask(_ task: TodoTask, userId: String) async throws {
        guard let taskId = task.id else {
            throw TaskServiceError.missingTaskID
        }
        try tasksCollection(for: userId).document(taskId).setData(from: task, merge: true)
    }

    func deleteTask(id: String, userId: String) async throws {
        try await tasksCollection(for: userId).document(id).delete()
    }
}

