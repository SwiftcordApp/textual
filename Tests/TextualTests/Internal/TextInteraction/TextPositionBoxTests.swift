#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import Testing

  @testable import Textual

  struct TextPositionBoxTests {
    @Test
    @MainActor
    func equivalentAffinitiesHaveTheSameIdentity() {
      let upstream = TextPositionBox(
        TextPosition(
          indexPath: .init(runSlice: 16, run: 0, line: 0, layout: 0),
          affinity: .upstream
        ),
        documentOffset: 17
      )
      let downstream = TextPositionBox(
        TextPosition(
          indexPath: .init(runSlice: 17, run: 0, line: 0, layout: 0),
          affinity: .downstream
        ),
        documentOffset: 17
      )

      #expect(upstream.isEqual(downstream))
      #expect(upstream.hash == downstream.hash)
      #expect(TextRangeBox(from: upstream, to: downstream).isEmpty)
    }
  }
#endif
