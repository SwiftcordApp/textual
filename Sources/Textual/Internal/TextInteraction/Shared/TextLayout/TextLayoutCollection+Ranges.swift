#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  extension TextLayoutCollection {
    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func wordRange(for position: TextPosition) -> TextRange? {
      guard layouts.indices.contains(position.indexPath.layout) else {
        return nil
      }
      let layout = layouts[position.indexPath.layout]
      let characterIndex = localCharacterIndex(at: position)

      guard
        let range = layout.wordRange(containing: characterIndex),
        let start = self.position(
          at: position.indexPath.layout,
          localCharacterIndex: range.lowerBound
        ),
        let end = self.position(
          at: position.indexPath.layout,
          localCharacterIndex: range.upperBound
        )
      else { return nil }

      return TextRange(start: start, end: end)
    }

    func blockRange(for position: TextPosition) -> TextRange? {
      let layoutIndex = position.indexPath.layout
      guard let end = selectableEndPosition(in: layoutIndex) else {
        return nil
      }
      return TextRange(
        start: .init(indexPath: .init(layout: layoutIndex), affinity: .downstream),
        end: end
      )
    }

    func clampRange(_ range: TextRange, layoutIndex: Int) -> TextRange? {
      guard layouts.indices.contains(layoutIndex) else {
        return nil
      }
      guard layouts[layoutIndex].selectionEndIndex != nil else {
        return range
      }
      guard let end = selectableEndPosition(in: layoutIndex) else {
        return nil
      }
      let start = TextPosition(
        indexPath: .init(layout: layoutIndex),
        affinity: .downstream
      )

      guard range.end > start && range.start < end else {
        return nil
      }

      return TextRange(
        start: Swift.max(range.start, start),
        end: Swift.min(range.end, end)
      )
    }
  }
#endif
