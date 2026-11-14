import Foundation
@testable import TodoApp

enum MockError: LocalizedError {
    case simulatedFailure

    var errorDescription: String? {
        "Simulated failure"
    }
}

final class MockAuthService: AuthServicing {
    var currentUserId: String?
    var shouldThrow = false
    private var authListeners: [(String?) -> Void] = []

    func observeAuthState(_ onChange: @escaping (String?) -> Void) -> () -> Void {
        authListeners.append(onChange)
        return {}
    }

    func signIn(email: String, password: String) async throws -> String {
        if shouldThrow { throw MockError.simulatedFailure }
        let uid = "uid-\(email)"
        currentUserId = uid
        authListeners.forEach { $0(uid) }
        return uid
    }

    func signUp(email: String, password: String) async throws -> String {
        if shouldThrow { throw MockError.simulatedFailure }
        let uid = "new-uid-\(email)"
        currentUserId = uid
        authListeners.forEach { $0(uid) }
        return uid
    }

    func signOut() throws {
        if shouldThrow { throw MockError.simulatedFailure }
        currentUserId = nil
        authListeners.forEach { $0(nil) }
    }
}

final class MockTaskService: TaskServicing {
    private var storage: [String: [TodoTask]] = [:]
    private var listeners: [String: ([TodoTask]) -> Void] = [:]
    var shouldThrow = false

    func observeTasks(
        userId: String,
        onChange: @escaping ([TodoTask]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> () -> Void {
        listeners[userId] = onChange
        onChange(storage[userId] ?? [])
        return { [weak self] in
            self?.listeners.removeValue(forKey: userId)
        }
    }

    func createTask(_ task: TodoTask, userId: String) async throws {
        if shouldThrow { throw MockError.simulatedFailure }
        var newTask = task
        newTask.id = newTask.id ?? UUID().uuidString
        var userTasks = storage[userId] ?? []
        userTasks.insert(newTask, at: 0)
        storage[userId] = userTasks
        listeners[userId]?(userTasks)
    }

    func updateTask(_ task: TodoTask, userId: String) async throws {
        if shouldThrow { throw MockError.simulatedFailure }
        guard let taskId = task.id else { throw TaskServiceError.missingTaskID }
        var userTasks = storage[userId] ?? []
        if let index = userTasks.firstIndex(where: { $0.id == taskId }) {
            userTasks[index] = task
        }
        storage[userId] = userTasks
        listeners[userId]?(userTasks)
    }

    func deleteTask(id: String, userId: String) async throws {
        if shouldThrow { throw MockError.simulatedFailure }
        var userTasks = storage[userId] ?? []
        userTasks.removeAll { $0.id == id }
        storage[userId] = userTasks
        listeners[userId]?(userTasks)
    }
}

