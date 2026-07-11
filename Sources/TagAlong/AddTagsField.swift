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
@available(iOS 17, macOS 14, *)
public struct AddTagsField: View {
    let label: String
    @Binding var tags: [Tag]
    let showAllTags: Bool
    var availableTags: [Tag]
    var delimiters: TokenDelimiters
    var maxTagLength: Int?

    @Environment(\.onTagCreated) private var onTagCreated
    @Environment(\.onTagRemoved) private var onTagRemoved
    @Environment(\.tagColorProvider) private var tagColorProvider

    public init(
        _ label: String = "Add Tag",
        tags: Binding<[Tag]>,
        showAllTags: Bool = false,
        availableTags: [Tag]? = nil,
        delimiters: TokenDelimiters = .returnKey,
        maxTagLength: Int? = nil
    ) {
        self.label = label
        _tags = tags
        self.showAllTags = showAllTags
        self.availableTags = availableTags ?? Array(TagStore.instance.knownTags.values)
        self.delimiters = delimiters
        self.maxTagLength = maxTagLength
    }

    public var body: some View {
        let colors = Dictionary(
            uniqueKeysWithValues: tags.map { tag in
                let color = tag.color != nil ? tag.tagColor : ((tagColorProvider?(tag))?.swiftUIColor ?? tag.tagColor)
                return (tag.name.lowercased(), color)
            }
        )
        TokenTextField(
            label,
            tokens: tokenNames,
            delimiters: delimiters,
            showTokens: showAllTags,
            tokenColors: colors,
            maxTagLength: maxTagLength,
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
                    if let existing = tags.first(where: { $0.name.lowercased() == name.lowercased() }) { return existing }
                    if let available = availableTags.first(where: { $0.name.lowercased() == name.lowercased() }) { return available }
                    var newTag = Tag(name)
                    if let provider = tagColorProvider { newTag.color = provider(newTag) }
                    return newTag
                }

                for tag in newTags where !oldLower.contains(tag.name.lowercased()) {
                    TagStore.register(tag)
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

@available(iOS 17, macOS 14, *)
#Preview {
    @Previewable @State var tags: [Tag] = [Tag("Swift", color: .orange), Tag("iOS", color: .blue)]
    let pool: [Tag] = [Tag("Swift", color: .orange), Tag("iOS", color: .blue), Tag("macOS", color: .purple), Tag("SwiftUI"), Tag("Xcode")]

    AddTagsField(tags: $tags, showAllTags: true, availableTags: pool)
        .padding()
}
