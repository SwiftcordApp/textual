import SwiftUI

// MARK: - Overview
//
// TextFragment renders attributed content as SwiftUI.Text with support for inline
// attachments, links, and selection. It uses a TextBuilder to construct and cache
// Text values, minimizing rebuilds during resize by keying on attachment sizes.
//
// Attachments are represented as placeholder images tagged with AttachmentAttribute. The
// actual attachment views are rendered in an overlay using the resolved Text.Layout
// geometry. Three modifiers are applied at the fragment level:
//
// - TextSelectionBackground renders selection highlights on macOS
// - AttachmentOverlay draws attachments at their run locations with selection-aware dimming
// - TextLinkInteraction handles tap gestures on links
//
// These overlays use backgroundPreferenceValue and overlayPreferenceValue to access
// Text.Layout and render in fragment-local coordinates. Fragment-level overlays enable
// coordinate space isolation and keep scrollable regions interactive.
//
// An ancestor view must define a named coordinate space (.textContainer) for the text
// container. TextFragment uses onGeometryChange to observe the container size and rebuild
// Text when attachment sizes need to change.
//
// TextFragment is used by InlineText and StructuredText (via BlockContent) to render
// attributed content with inline attachments, links, and selection.

struct TextFragment<Content: AttributedStringProtocol>: View {
  @Environment(\.textEnvironment) private var textEnvironment
  @StateObject private var textBuilders =
    ViewOutputCache<Tuple<Content, TextEnvironmentValues>, TextBuilder>()

  private let content: Content

  init(_ content: Content) {
    self.content = content
  }

  var body: some View {
    let textBuilder = textBuilder
    let attachments = content.attachments()

    fragment(textBuilder.text, attachments: attachments)
      .modifier(AttachmentGeometryModifier(textBuilder: textBuilder, attachments: attachments))
  }

  private func fragment(_ text: Text, attachments: Set<AnyAttachment>) -> some View {
    text
      .customAttribute(TextFragmentAttribute())
      .modifier(TextSelectionBackground())
      .modifier(AttachmentOverlay(attachments: attachments))
      .modifier(TextLinkInteraction())
  }

  // The builder must exist synchronously for correct first-pass measurement, but copying it into
  // @State after that pass needlessly lays out the same text again. The retained builder still
  // publishes real attachment-size changes through Observation.
  private var textBuilder: TextBuilder {
    let key = Tuple(content, textEnvironment)
    return textBuilders.output(for: key) {
      TextBuilder(key.values.0, environment: key.values.1)
    }
  }
}

private struct AttachmentGeometryModifier<
  AttributedContent: AttributedStringProtocol
>: ViewModifier {
  @Environment(\.textEnvironment) private var textEnvironment

  let textBuilder: TextFragment<AttributedContent>.TextBuilder
  let attachments: Set<AnyAttachment>

  @ViewBuilder
  func body(content: Content) -> some View {
    if attachments.isEmpty {
      content
    } else {
      content.onGeometryChange(for: CGSize?.self, of: \.textContainerSize) { size in
        guard let size else { return }
        textBuilder.sizeChanged(size, environment: textEnvironment)
      }
    }
  }
}

struct TextFragmentAttribute: TextAttribute {
}

extension Text.Layout {
  var isTextFragment: Bool {
    first?.first?[TextFragmentAttribute.self] != nil
  }
}

extension CoordinateSpaceProtocol where Self == NamedCoordinateSpace {
  static var textContainer: NamedCoordinateSpace {
    .named("textContainer")
  }
}

extension GeometryProxy {
  fileprivate var textContainerSize: CGSize? {
    bounds(of: .textContainer)?.size
  }
}
