import Testing

@testable import Textual

struct InlineTextTests {
  @Test func parseInputIncludesParseDependency() {
    let initial = InlineText.ParseInput(markup: "Hello", parseDependency: false)

    #expect(initial == InlineText.ParseInput(markup: "Hello", parseDependency: false))
    #expect(initial != InlineText.ParseInput(markup: "Hello", parseDependency: true))
  }
}
