import XCTest
@testable import TodoApp

@MainActor
final class AuthViewModelTests: XCTestCase {
    func testInvalidEmailShowsValidationError() async {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.email = "invalid-email"
        viewModel.password = "123456"

        await viewModel.submit()

        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email address.")
        XCTAssertNil(viewModel.currentUserId)
    }

    func testShortPasswordShowsValidationError() async {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.email = "user@example.com"
        viewModel.password = "123"

        await viewModel.submit()

        XCTAssertEqual(viewModel.errorMessage, "Password must be at least 6 characters.")
        XCTAssertNil(viewModel.currentUserId)
    }

    func testSignInSuccessUpdatesCurrentUserIdAndClearsPassword() async {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.email = "user@example.com"
        viewModel.password = "secret123"

        await viewModel.submit()

        XCTAssertEqual(viewModel.currentUserId, "uid-user@example.com")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSignUpSuccessUpdatesCurrentUserId() async {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.toggleMode()
        viewModel.email = "new@example.com"
        viewModel.password = "secret123"

        await viewModel.submit()

        XCTAssertEqual(viewModel.currentUserId, "new-uid-new@example.com")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSignOutClearsCurrentUserId() async {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.email = "user@example.com"
        viewModel.password = "secret123"
        await viewModel.submit()

        viewModel.signOut()

        XCTAssertNil(viewModel.currentUserId)
    }
}

