//
//  TokenTextField.swift
//  TagAlong
//

import SwiftUI

/// Which typed characters automatically commit the current input as a new token.
public struct TokenDelimiters: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let space     = TokenDelimiters(rawValue: 1 << 0)
    public static let returnKey = TokenDelimiters(rawValue: 1 << 1)
    public static let comma     = TokenDelimiters(rawValue: 1 << 2)

    public static let all: TokenDelimiters = [.space, .returnKey, .comma]
}

/// A string-based token text field. Shows existing tokens as removable capsules
/// and creates new tokens when delimiter characters are typed. Token matching is
/// always case-insensitive — "Swift" and "swift" are the same token.
///
/// Pass `tokenColors` to give specific tokens a background color (keyed by
/// lowercased token name). Pass a `suggestionsProvider` closure to show an
/// autocomplete row while the field is focused.
@available(iOS 17, macOS 14, *)
public struct TokenTextField: View {
    @Binding var tokens: [String]
    var placeholder: String
    var delimiters: TokenDelimiters
    var showTokens: Bool
    var tokenColors: [String: Color]
    var maxTagLength: Int?
    var suggestionsProvider: ((String) -> [String])?

    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    public init(
        _ placeholder: String = "Add tag",
        tokens: Binding<[String]>,
        delimiters: TokenDelimiters = .space,
        showTokens: Bool = true,
        tokenColors: [String: Color] = [:],
        maxTagLength: Int? = nil,
        suggestionsProvider: ((String) -> [String])? = nil
    ) {
        self.placeholder = placeholder
        _tokens = tokens
        self.delimiters = delimiters
        self.showTokens = showTokens
        self.tokenColors = tokenColors
        self.maxTagLength = maxTagLength
        self.suggestionsProvider = suggestionsProvider
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showTokens {
                FlowLayout(spacing: 4, lineSpacing: 4, stretchLast: true) {
                    ForEach(tokens, id: \.self) { token in
                        tokenCapsule(token)
                    }
                    inputField
                        .frame(minWidth: 80)
                }
            } else {
                inputField
            }

            if isFocused, let provider = suggestionsProvider {
                let suggestions = provider(inputText)
                if !suggestions.isEmpty {
                    suggestionsRow(suggestions)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    private var inputField: some View {
        TextField(placeholder, text: $inputText)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .submitLabel(delimiters.contains(.returnKey) ? .continue : .done)
            .onSubmit {
                if delimiters.contains(.returnKey) { commitInput() }
            }
            .onChange(of: inputText) { _, new in
                if let max = maxTagLength, new.count > max {
                    inputText = String(new.prefix(max))
                    return
                }
                handleDelimiters(in: new)
            }
    }

    private func suggestionsRow(_ suggestions: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(suggestions, id: \.self) { token in
                    Button { addToken(token) } label: {
                        Text(token)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.tertiary, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func tokenCapsule(_ token: String) -> some View {
        let bg = tokenColors[token.lowercased()] ?? Color.accentColor.opacity(0.15)
        return HStack(spacing: 3) {
            Text(token)
                .lineLimit(1)
                .truncationMode(.middle)
            Button { removeToken(token) } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(bg)
        .foregroundStyle(bg.textColor)
        .clipShape(Capsule())
        .frame(maxWidth: 200)
    }

    private func handleDelimiters(in text: String) {
        guard let last = text.last else { return }
        let isSpaceDelim = delimiters.contains(.space) && last == " "
        let isCommaDelim = delimiters.contains(.comma) && last == ","
        guard isSpaceDelim || isCommaDelim else { return }

        let name = text.dropLast().trimmingCharacters(in: .whitespaces)
        if name.isEmpty { inputText = "" } else { addToken(name) }
    }

    private func commitInput() {
        let name = inputText.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        addToken(name)
    }

    private func addToken(_ token: String) {
        let trimmed = token.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !tokens.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
            inputText = ""
            Task { @MainActor in isFocused = true }
            return
        }
        tokens.append(trimmed)
        inputText = ""
        Task { @MainActor in isFocused = true }
    }

    private func removeToken(_ token: String) {
        tokens.removeAll { $0.lowercased() == token.lowercased() }
    }
}

@available(iOS 17, macOS 14, *)
#Preview {
    @Previewable @State var tokens: [String] = ["Swift", "iOS"]
    let pool = ["Swift", "iOS", "macOS", "SwiftUI", "Xcode"]
    let colors: [String: Color] = ["swift": .orange, "ios": .blue, "macos": .purple]

    TokenTextField(tokens: $tokens, delimiters: .all, tokenColors: colors) { input in
        let lower = input.lowercased()
        return pool.filter { t in
            !tokens.contains(where: { $0.lowercased() == t.lowercased() })
            && (input.isEmpty || t.lowercased().contains(lower))
        }
    }
    .padding(8)
    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    .padding()
}
