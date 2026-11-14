import SwiftUI

/// Email/password login and registration screen.
struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.system(size: 52))
                        .foregroundStyle(.tint)
                    Text(viewModel.isSignUpMode ? "Create Account" : "Welcome Back")
                        .font(.largeTitle.bold())
                    Text("Sign in to sync your tasks with Firebase")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("Password (min 6 characters)", text: $viewModel.password)
                        .textContentType(viewModel.isSignUpMode ? .newPassword : .password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(viewModel.isSignUpMode ? "Sign Up" : "Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Button {
                    viewModel.toggleMode()
                } label: {
                    Text(
                        viewModel.isSignUpMode
                            ? "Already have an account? Sign In"
                            : "Don't have an account? Sign Up"
                    )
                    .font(.subheadline)
                }
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

