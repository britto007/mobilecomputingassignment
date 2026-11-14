import SwiftUI

/// Main authenticated screen showing the user's real-time Firestore tasks.
struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var isPresentingCreateSheet = false
    @State private var taskToEdit: TodoTask?

    private let onSignOut: () -> Void

    init(userId: String, taskService: TaskServicing, onSignOut: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: TaskListViewModel(userId: userId, taskService: taskService)
        )
        self.onSignOut = onSignOut
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Loading tasks...")
                } else if viewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out", role: .destructive) {
                        onSignOut()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(isPresented: $isPresentingCreateSheet) {
                TaskFormView { title, description, _ in
                    await viewModel.addTask(title: title, description: description)
                }
            }
            .sheet(item: $taskToEdit) { task in
                TaskFormView(existingTask: task) { title, description, isCompleted in
                    await viewModel.updateTask(
                        task,
                        title: title,
                        description: description,
                        isCompleted: isCompleted
                    )
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task) {
                    Task { await viewModel.toggleCompletion(task) }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    taskToEdit = task
                }
            }
            .onDelete { offsets in
                Task { await viewModel.deleteTasks(at: offsets) }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No Tasks Yet")
                .font(.headline)
            Text("Tap + to create your first task.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

