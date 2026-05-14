//
//  AddTagsField.swift
//  TagAlong
//

import SwiftUI

/// A styled tag input field with autocomplete sourced from `availableTags`.
///
/// When `showAllTags` is `true`, all selected tags are displayed as colored
/// token capsules inside the field. When `false`, only the text input is shown
/// (the caller is responsible for displaying the current selection elsewhere).
@available(iOS 17.0, macOS 15, *)
public struct AddTagsField: View {
    let label: String
    @Binding var tags: [Tag]
    let showAllTags: Bool
    var availableTags: [Tag]
    var delimiters: TokenDelimiters

    @Environment(\.onTagCreated) private var onTagCreated
    @Environment(\.onTagRemoved) private var onTagRemoved

    public init(
        _ label: String = "Add Tag",
        tags: Binding<[Tag]>,
        showAllTags: Bool = false,
        availableTags: [Tag]? = nil,
        delimiters: TokenDelimiters = .returnKey
    ) {
        self.label = label
        _tags = tags
        self.showAllTags = showAllTags
        self.availableTags = availableTags ?? Array(TagStore.instance.knownTags.values)
        self.delimiters = delimiters
    }

    public var body: some View {
        let colors = Dictionary(
            uniqueKeysWithValues: tags.map { ($0.name.lowercased(), $0.tagColor) }
        )
        TokenTextField(
            label,
            tokens: tokenNames,
            delimiters: delimiters,
            showTokens: showAllTags,
            tokenColors: colors,
            suggestionsProvider: suggestions
        )
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    /// Bridges `[Tag]` ↔ `[String]` for `TokenTextField`, preserving existing
    /// tag objects (and their colors) when names round-trip through the field.
    private var tokenNames: Binding<[String]> {
        Binding(
            get: { tags.map(\.name) },
            set: { newNames in
                let oldLower = tags.map { $0.name.lowercased() }
                let newLower = newNames.map { $0.lowercased() }

                for tag in tags where !newLower.contains(tag.name.lowercased()) {
                    onTagRemoved?(tag)
                }

                let newTags: [Tag] = newNames.map { name in
                    tags.first { $0.name.lowercased() == name.lowercased() }
                        ?? availableTags.first { $0.name.lowercased() == name.lowercased() }
                        ?? Tag(name)
                }

                for tag in newTags where !oldLower.contains(tag.name.lowercased()) {
                    onTagCreated?(tag)
                }

                tags = newTags
            }
        )
    }

    private func suggestions(for input: String) -> [String] {
        guard !input.isEmpty else { return [] }
        let selectedLower = tags.map { $0.name.lowercased() }
        let query = input.lowercased()
        return availableTags
            .filter { !selectedLower.contains($0.name.lowercased()) && $0.name.lowercased().contains(query) }
            .map(\.name)
    }
}

@available(iOS 17.0, macOS 15, *)
#Preview {
    @Previewable @State var tags: [Tag] = [Tag("Swift", color: .orange), Tag("iOS", color: .blue)]
    let pool: [Tag] = [Tag("Swift", color: .orange), Tag("iOS", color: .blue), Tag("macOS", color: .purple), Tag("SwiftUI"), Tag("Xcode")]

    AddTagsField(tags: $tags, showAllTags: true, availableTags: pool)
        .padding()
}
