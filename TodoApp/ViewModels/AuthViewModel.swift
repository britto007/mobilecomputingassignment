import Foundation

/// Coordinates email/password authentication state and form validation.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isSignUpMode = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var currentUserId: String?

    private let authService: AuthServicing
    private var stopObservingAuth: (() -> Void)?

    init(authService: AuthServicing) {
        self.authService = authService
        self.currentUserId = authService.currentUserId
        self.stopObservingAuth = authService.observeAuthState { [weak self] uid in
            Task { @MainActor [weak self] in
                self?.currentUserId = uid
            }
        }
    }

    deinit {
        stopObservingAuth?()
    }

    /// Submits either sign-in or sign-up based on `isSignUpMode`.
    func submit() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if isSignUpMode {
                currentUserId = try await authService.signUp(email: trimmedEmail, password: password)
            } else {
                currentUserId = try await authService.signIn(email: trimmedEmail, password: password)
            }
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Toggles between Sign In and Create Account modes and clears stale errors.
    func toggleMode() {
        isSignUpMode.toggle()
        errorMessage = nil
    }

    /// Signs out the current user.
    func signOut() {
        do {
            try authService.signOut()
            currentUserId = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

