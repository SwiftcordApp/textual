import SwiftUI

/// Displays inline attributed content from markup with support for inline attachments,
/// links, and text selection on supported platforms.
///
/// Use `InlineText` to render single-line or flowing text with rich formatting. The view
/// parses markup into styled text, automatically handling images, custom emoji, links,
/// and standard formatting like bold and italic.
///
/// ```swift
/// InlineText(
///   markdown: "**Working late** has been surprisingly fun—_even when the build fails_."
/// )
/// ```
///
/// For multi-paragraph content with headings, lists, and code blocks, use ``StructuredText``
/// instead.
///
/// ### Customizing Text Appearance
///
/// `InlineText` supports standard SwiftUI text modifiers like `.font()`, `.foregroundStyle()`,
/// and `.multilineTextAlignment()`:
///
/// ```swift
/// InlineText(markdown: "Hello, **world**!")
///   .font(.title3)
///   .foregroundStyle(.secondary)
///   .multilineTextAlignment(.center)
/// ```
///
/// ### Inline Attachments
///
/// Images and custom emoji render inline with the surrounding text:
///
/// ```swift
/// InlineText(
///   markdown: "Here is an inline image ![dog](https://picsum.photos/id/237/200/300)."
/// )
/// ```
///
/// Images are decoded using the system image codecs. Supported formats typically include JPEG and
/// PNG, animated GIF and APNG, WebP, and HEIC/HEICS.
///
/// Custom emoji can be defined and substituted using syntax extensions:
///
/// ```swift
/// let emoji: Set<Emoji> = [
///   Emoji(
///     shortcode: "doge",
///     url: URL(string: "https://picsum.photos/id/237/32/32")!
///   ),
///   Emoji(
///     shortcode: "confused_dog",
///     url: URL(string: "https://picsum.photos/id/1025/32/32")!
///   ),
/// ]
///
/// InlineText(
///   markdown: "Even when the build fails :confused_dog:, a quick refactor helps :doge:.",
///   syntaxExtensions: [.emoji(emoji)]
/// )
/// ```
///
/// Math expressions are supported when you include `.math` in `syntaxExtensions`:
///
/// ```swift
/// InlineText(
///   markdown: "The area is $A = \\pi r^2$.",
///   syntaxExtensions: [.math]
/// )
/// ```
///
/// ### Links
///
/// Links use SwiftUI's `openURL` environment action. To customize link handling, override it:
///
/// ```swift
/// InlineText(markdown: "Open [Textual](https://github.com/gonzalezreal/Textual)")
///   .environment(\.openURL, OpenURLAction { url in
///     print("Opening:", url)
///     return .handled
///   })
/// ```
///
/// ### Styling
///
/// Customize the appearance of inline elements using ``InlineStyle``:
///
/// ```swift
/// let style = InlineStyle()
///   .code(.monospaced, .foregroundColor(.purple))
///   .strong(.fontWeight(.bold))
///
/// InlineText(markdown: "Use `git status` to check **uncommitted** changes")
///   .textual.inlineStyle(style)
/// ```
public struct InlineText: View {
  @State private var attributedString = AttributedString()

  private let markup: String
  private let parser: any MarkupParser
  private let resolvesURLAttachments: Bool

  /// Creates inline text from markup using the given ``MarkupParser`` implementation.
  ///
  /// - Parameters:
  ///   - markup: The markup string to parse and display.
  ///   - parser: The parser to use for converting markup to attributed content.
  ///   - resolvesURLAttachments: Whether Textual should resolve `imageURL` and `emojiURL`
  ///     attributes into attachments before rendering. Pass `false` when the parser emits final
  ///     `textual.attachment` values directly and cannot produce URL-backed attachments.
  public init(
    _ markup: String,
    parser: any MarkupParser,
    resolvesURLAttachments: Bool = true
  ) {
    self.markup = markup
    self.parser = parser
    self.resolvesURLAttachments = resolvesURLAttachments
  }

  public var body: some View {
    content
      .coordinateSpace(.textContainer)
      .onChange(of: markup, initial: true) { _, value in
        self.attributedString = (try? parser.attributedString(for: value)) ?? .init()
      }
  }

  @ViewBuilder private var content: some View {
    if resolvesURLAttachments {
      WithAttachments(attributedString) {
        styledText($0)
      }
    } else {
      styledText(attributedString)
    }
  }

  private func styledText(_ attributedString: AttributedString) -> some View {
    WithInlineStyle(attributedString) {
      TextFragment($0)
        .modifier(TextSelectionInteraction())
    }
  }
}

extension InlineText {
  /// Creates inline text from a markdown string.
  ///
  /// This convenience initializer uses the built-in markdown parser with support for
  /// standard CommonMark formatting, inline images, and custom emoji substitution.
  ///
  /// - Parameters:
  ///   - markdown: The markdown string to parse and display.
  ///   - baseURL: The base URL to use when resolving Markdown URLs. The initializer treats URLs as
  ///     being relative to this URL. If this value is `nil`, the initializer doesn’t resolve URLs.
  ///     The default is `nil`.
  ///   - syntaxExtensions: Custom syntax extensions applied after markdown parsing.
  ///   - resolvesURLAttachments: Whether Textual should resolve URL-backed attachment attributes
  ///     before rendering.
  public init(
    markdown: String,
    baseURL: URL? = nil,
    syntaxExtensions: [AttributedStringMarkdownParser.SyntaxExtension] = [],
    resolvesURLAttachments: Bool = true
  ) {
    self.init(
      markdown,
      parser: .inlineMarkdown(
        baseURL: baseURL,
        syntaxExtensions: syntaxExtensions
      ),
      resolvesURLAttachments: resolvesURLAttachments
    )
  }
}

// MARK: - Previews

@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview("Custom Emoji") {
  ScrollView {
    InlineText(
      markdown: """
        **Working late on the new feature** has been surprisingly fun—_even when the build \
        fails_ :confused_dog:, a quick refactor usually gets things back on track :doge:, \
        and when it doesn’t, I just roll with it :dogroll: until the solution finally \
        clicks (though sometimes I still end up a bit :sad_dog:).
        """,
      syntaxExtensions: [.emoji(.previewEmoji)]
    )
    .padding()
  }
  .textual.textSelection(.enabled)
}
