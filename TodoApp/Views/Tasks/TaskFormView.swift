import SwiftUI

/// Modal form used for both creating a new task and editing an existing task.
struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss

    let existingTask: TodoTask?
    let onSave: (String, String, Bool) async -> Void

    @State private var title: String
    @State private var description: String
    @State private var isCompleted: Bool
    @State private var isSaving = false

    init(
        existingTask: TodoTask? = nil,
        onSave: @escaping (String, String, Bool) async -> Void
    ) {
        self.existingTask = existingTask
        self.onSave = onSave
        _title = State(initialValue: existingTask?.title ?? "")
        _description = State(initialValue: existingTask?.description ?? "")
        _isCompleted = State(initialValue: existingTask?.isCompleted ?? false)
    }

    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Enter task title", text: $title)
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 120)
                }

                if existingTask != nil {
                    Section {
                        Toggle("Completed", isOn: $isCompleted)
                    }
                }
            }
            .navigationTitle(existingTask == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            await onSave(title, description, isCompleted)
                            isSaving = false
                            dismiss()
                        }
                    }
                    .disabled(!isTitleValid || isSaving)
                }
            }
        }
    }
}

