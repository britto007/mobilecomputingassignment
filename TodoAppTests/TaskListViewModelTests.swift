import XCTest
@testable import TodoApp

@MainActor
final class TaskListViewModelTests: XCTestCase {
    func testAddUpdateToggleAndDeleteTask() async throws {
        let taskService = MockTaskService()
        let viewModel = TaskListViewModel(userId: "user-1", taskService: taskService)

        // Create
        await viewModel.addTask(title: "Buy groceries", description: "Milk and eggs")
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.tasks.count, 1)
        let created = try XCTUnwrap(viewModel.tasks.first)
        XCTAssertEqual(created.title, "Buy groceries")
        XCTAssertEqual(created.description, "Milk and eggs")
        XCTAssertFalse(created.isCompleted)

        // Toggle completion
        await viewModel.toggleCompletion(created)
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(viewModel.tasks.first?.isCompleted == true)

        // Update title & description
        let toggled = try XCTUnwrap(viewModel.tasks.first)
        await viewModel.updateTask(
            toggled,
            title: "Buy organic groceries",
            description: "Almond milk and eggs",
            isCompleted: false
        )
        try await Task.sleep(nanoseconds: 50_000_000)

        let updated = try XCTUnwrap(viewModel.tasks.first)
        XCTAssertEqual(updated.title, "Buy organic groceries")
        XCTAssertEqual(updated.description, "Almond milk and eggs")
        XCTAssertFalse(updated.isCompleted)

        // Delete
        await viewModel.deleteTask(updated)
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(viewModel.tasks.isEmpty)
    }

    func testEmptyTitleIsRejected() async {
        let taskService = MockTaskService()
        let viewModel = TaskListViewModel(userId: "user-1", taskService: taskService)

        await viewModel.addTask(title: "   ", description: "No title")

        XCTAssertEqual(viewModel.errorMessage, "Task title cannot be empty.")
        XCTAssertTrue(viewModel.tasks.isEmpty)
    }
}

