import Foundation

/// Manages real-time task synchronization and CRUD operations for a signed-in user.
@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let userId: String
    private let taskService: TaskServicing
    private var stopObservingTasks: (() -> Void)?

    init(userId: String, taskService: TaskServicing) {
        self.userId = userId
        self.taskService = taskService
        startObserving()
    }

    deinit {
        stopObservingTasks?()
    }

    /// Creates a new task with a non-empty title and optional description.
    func addTask(title: String, description: String) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Task title cannot be empty."
            return
        }

        let newTask = TodoTask(
            title: trimmedTitle,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        await performTaskOperation {
            try await taskService.createTask(newTask, userId: userId)
        }
    }

    /// Updates an existing task's title, description, and completion status.
    func updateTask(
        _ task: TodoTask,
        title: String,
        description: String,
        isCompleted: Bool
    ) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Task title cannot be empty."
            return
        }

        var updated = task
        updated.title = trimmedTitle
        updated.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.isCompleted = isCompleted

        await performTaskOperation {
            try await taskService.updateTask(updated, userId: userId)
        }
    }

    /// Toggles the `isCompleted` flag on a task.
    func toggleCompletion(_ task: TodoTask) async {
        var updated = task
        updated.isCompleted.toggle()
        await performTaskOperation {
            try await taskService.updateTask(updated, userId: userId)
        }
    }

    /// Deletes tasks at the specified list offsets.
    func deleteTasks(at offsets: IndexSet) async {
        let targets = offsets.compactMap { tasks.indices.contains($0) ? tasks[$0] : nil }
        for task in targets {
            await deleteTask(task)
        }
    }

    /// Deletes a single task by its document ID.
    func deleteTask(_ task: TodoTask) async {
        guard let taskId = task.id else {
            errorMessage = TaskServiceError.missingTaskID.localizedDescription
            return
        }
        await performTaskOperation {
            try await taskService.deleteTask(id: taskId, userId: userId)
        }
    }

    private func startObserving() {
        stopObservingTasks = taskService.observeTasks(
            userId: userId,
            onChange: { [weak self] tasks in
                Task { @MainActor [weak self] in
                    self?.tasks = tasks
                    self?.isLoading = false
                }
            },
            onError: { [weak self] error in
                Task { @MainActor [weak self] in
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        )
    }

    private func performTaskOperation(_ operation: () async throws -> Void) async {
        errorMessage = nil
        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

