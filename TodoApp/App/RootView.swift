import SwiftUI

/// Routes between authentication and the user's task list based on auth state.
struct RootView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let taskService: TaskServicing

    var body: some View {
        Group {
            if let userId = authViewModel.currentUserId {
                TaskListView(
                    userId: userId,
                    taskService: taskService,
                    onSignOut: { authViewModel.signOut() }
                )
                .id(userId)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
    }
}

