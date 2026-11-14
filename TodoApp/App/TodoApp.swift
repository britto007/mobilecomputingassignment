import SwiftUI
import FirebaseCore

@main
struct TodoApp: App {
    @StateObject private var authViewModel: AuthViewModel
    private let taskService: TaskServicing

    init() {
        FirebaseApp.configure()
        let authService = FirebaseAuthService()
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.taskService = FirestoreTaskService()
    }

    var body: some Scene {
        WindowGroup {
            RootView(authViewModel: authViewModel, taskService: taskService)
        }
    }
}

