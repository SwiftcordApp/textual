#if TEXTUAL_ENABLE_TEXT_SELECTION
  import Foundation
  import SwiftUI
  import Testing

  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
  #endif

  @testable import Textual

  extension TextSelectionModelTests {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
      @Test
      @MainActor
      func resigningTextInteractionClearsSelection() throws {
        let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
        model.selectedRange = TextRange(start: model.startPosition, end: model.endPosition)
        let interactionView = NSTextInteractionView(
          model: model,
          exclusionRects: [],
          openURL: OpenURLAction { _ in .handled }
        )
        let textField = NSTextField()
        let container = NSView()
        container.addSubview(interactionView)
        container.addSubview(textField)
        let window = NSWindow(
          contentRect: .zero,
          styleMask: [],
          backing: .buffered,
          defer: false
        )
        window.contentView = container

        #expect(window.makeFirstResponder(interactionView))

        #expect(window.makeFirstResponder(textField))
        #expect(model.selectedRange == nil)
      }
    #endif

    @Test
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func wordRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 2, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )  // The 'm' in "sample"
      let expected = TextRange(
        start: .init(
          indexPath: .init(runSlice: 9, run: 0, line: 0, layout: 0),
          affinity: .upstream
        ),
        end: .init(
          indexPath: .init(runSlice: 5, run: 1, line: 0, layout: 0),
          affinity: .upstream
        )
      )

      // when
      let range = model.wordRange(for: position)

      // then
      #expect(range == expected)
    }

    @Test
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func nextWordWithinLayout() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 2, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )  // The 'm' in "sample"
      let expected = TextPosition(
        indexPath: .init(runSlice: 5, run: 1, line: 0, layout: 0),
        affinity: .upstream
      )

      // when
      let next = model.nextWord(from: position)

      // then
      #expect(next == expected)
    }

    @Test
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func nextWordAcrossLayouts() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
        affinity: .upstream
      )
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 1),
        affinity: .downstream
      )

      // when
      let next = model.nextWord(from: position)

      // then
      #expect(next == expected)
    }

    @Test
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func previousWordWithinLayout() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 2, line: 0, layout: 0),
        affinity: .downstream
      )
      let expected = TextPosition(
        indexPath: .init(runSlice: 9, run: 0, line: 0, layout: 0),
        affinity: .upstream
      )

      // when
      let prev = model.previousWord(from: position)

      // then
      #expect(prev == expected)
    }

    @Test
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func previousWordAcrossLayouts() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 1),
        affinity: .downstream
      )
      let expected = TextPosition(
        indexPath: .init(runSlice: 3, run: 0, line: 1, layout: 0),
        affinity: .upstream
      )

      // when
      let prev = model.previousWord(from: position)

      // then
      #expect(prev == expected)
    }
  }
#endif
