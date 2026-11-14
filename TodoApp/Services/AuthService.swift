import Foundation
import FirebaseAuth

/// Abstraction over authentication operations for testability.
protocol AuthServicing {
    /// Returns the currently signed-in user's unique identifier, if any.
    var currentUserId: String? { get }

    /// Subscribes to authentication state changes and returns a cancellation closure.
    func observeAuthState(_ onChange: @escaping (String?) -> Void) -> () -> Void

    /// Signs in an existing user with email and password, returning their UID.
    func signIn(email: String, password: String) async throws -> String

    /// Registers a new user with email and password, returning their UID.
    func signUp(email: String, password: String) async throws -> String

    /// Signs out the current user.
    func signOut() throws
}

/// Firebase Authentication implementation of `AuthServicing`.
final class FirebaseAuthService: AuthServicing {
    private let auth: Auth

    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    var currentUserId: String? {
        auth.currentUser?.uid
    }

    func observeAuthState(_ onChange: @escaping (String?) -> Void) -> () -> Void {
        let handle = auth.addStateDidChangeListener { _, user in
            onChange(user?.uid)
        }
        return { [weak auth] in
            auth?.removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user.uid
    }

    func signUp(email: String, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signOut() throws {
        try auth.signOut()
    }
}

