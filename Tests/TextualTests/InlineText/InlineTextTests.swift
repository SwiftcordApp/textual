import SwiftUI
import Testing

@testable import Textual

@MainActor
struct InlineTextTests {
  @Test func parseInputIncludesParseDependency() {
    let initial = InlineText.ParseInput(markup: "Hello", parseDependency: false)

    #expect(initial == InlineText.ParseInput(markup: "Hello", parseDependency: false))
    #expect(initial != InlineText.ParseInput(markup: "Hello", parseDependency: true))
  }

  @Test func emptyParserOutputHasNoLayoutHeight() {
    #expect(renderedSize(for: AttributedString("")).height == 0)
    #expect(renderedSize(for: AttributedString("Visible")).height > 0)
  }

  private func renderedSize(for output: AttributedString) -> CGSize {
    let renderer = ImageRenderer(
      content: InlineText("source", parser: OutputParser(output: output))
    )
    var renderedSize: CGSize?
    renderer.render { size, _ in
      renderedSize = size
    }
    return renderedSize ?? .zero
  }

  private struct OutputParser: MarkupParser {
    let output: AttributedString

    func attributedString(for _: String) throws -> AttributedString {
      output
    }
  }
}
