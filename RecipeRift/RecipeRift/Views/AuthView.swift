
//
//  AuthView.swift
//  RecipeRift
//

import SwiftUI

struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var logoShown = false
    @State private var formShown = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("displayName") private var displayName = "Chef"

    var body: some View {
        ZStack {
            // ── Background ─────────────────────────────────────────────────
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.12, blue: 0.07), Color(red: 0.02, green: 0.06, blue: 0.03)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle decorative circles
            Circle()
                .fill(Color.brandGreen.opacity(0.12))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: -80, y: -200)
            Circle()
                .fill(Color.brandGreenLight.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 130, y: 250)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    Spacer(minLength: 60)

                    // ── Logo ───────────────────────────────────────────────
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.brandGreen)
                                .frame(width: 84, height: 84)
                                .shadow(color: Color.brandGreen.opacity(0.5), radius: 20, x: 0, y: 10)
                            Image(systemName: "fork.knife")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(logoShown ? 1 : 0.5)
                        .opacity(logoShown ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) {
                                logoShown = true
                            }
                        }

                        VStack(spacing: 6) {
                            Text("RecipeRift")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Cook smarter, eat better")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.55))
                        }
                    }
                    .padding(.bottom, 48)

                    // ── Frosted Glass Form Card ────────────────────────────
                    VStack(spacing: 0) {

                        // Segment switcher
                        HStack(spacing: 0) {
                            ForEach(["Sign In", "Create Account"], id: \.self) { mode in
                                let isActive = (mode == "Sign In") == isLogin
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        isLogin = (mode == "Sign In")
                                    }
                                } label: {
                                    Text(mode)
                                        .font(.subheadline)
                                        .fontWeight(isActive ? .bold : .regular)
                                        .foregroundColor(isActive ? .white : Color.white.opacity(0.45))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            isActive ?
                                            Color.brandGreen.clipShape(RoundedRectangle(cornerRadius: 10)) :
                                            Color.clear.clipShape(RoundedRectangle(cornerRadius: 10))
                                        )
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                        // Fields
                        VStack(spacing: 14) {
                            if !isLogin {
                                AuthField(icon: "person.fill", placeholder: "Full Name", text: $name, isSecure: false)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            AuthField(icon: "envelope.fill", placeholder: "Email Address", text: $email, isSecure: false)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            AuthField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                        }
                        .padding(.horizontal, 20)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isLogin)

                        // Forgot password
                        if isLogin {
                            HStack {
                                Spacer()
                                Button("Forgot password?") {}
                                    .font(.footnote)
                                    .foregroundColor(Color.brandGreen.opacity(0.9))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }

                        // CTA Button
                        Button {
                            let resolvedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !resolvedName.isEmpty {
                                displayName = resolvedName
                            } else if let emailPrefix = email.split(separator: "@").first, !emailPrefix.isEmpty {
                                displayName = String(emailPrefix)
                            }
                            withAnimation { isLoggedIn = true }
                        } label: {
                            Text(isLogin ? "Sign In" : "Create Account")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.brandGreen)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color.brandGreen.opacity(0.5), radius: 10, x: 0, y: 6)
                        }
                        .buttonStyle(SpringButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                        .padding(.bottom, 28)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
                    .padding(.horizontal, 20)
                    .opacity(formShown ? 1 : 0)
                    .offset(y: formShown ? 0 : 30)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5).delay(0.25)) { formShown = true }
                    }

                    // Social options
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                            Text("or continue with").font(.caption).foregroundColor(Color.white.opacity(0.4)).fixedSize()
                            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 14) {
                            SocialButton(icon: "apple.logo", label: "Apple")
                            SocialButton(icon: "g.circle.fill", label: "Google")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 22)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

// MARK: - Auth Field
private struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.white.opacity(0.5))
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.brandGreen)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.brandGreen)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

// MARK: - Social Button
private struct SocialButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 16))
                Text(label).font(.subheadline).fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.white.opacity(0.09))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(SpringButtonStyle())
    }
}

#Preview {
    AuthView()
}
