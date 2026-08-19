#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  // MARK: - Overview
  //
  // `TextSelectionModel` is the shared state object that backs selection and interaction.
  //
  // Platform views (AppKit/UIKit) mutate `selectedRange` in response to gestures and editing
  // commands. The model delegates layout-specific work to a `TextLayoutCollection`, which can be
  // rebuilt at any time as SwiftUI resolves new `Text.Layout` values. When the layout collection
  // changes, the model attempts to reconcile the current selection into the new layout so the
  // selection stays stable across updates.

  @Observable
  final class TextSelectionModel {
    var selectedRange: TextRange? {
      willSet {
        selectionWillChange?()
      }
      didSet {
        if selectedRange != nil {
          coordinator?.modelDidSelectText(self)
        }
        selectionDidChange?()
      }
    }

    @ObservationIgnored
    var selectionWillChange: (() -> Void)?

    @ObservationIgnored
    var selectionDidChange: (() -> Void)?

    @ObservationIgnored
    private var layoutCollection: any TextLayoutCollection

    @ObservationIgnored
    private weak var coordinator: TextSelectionCoordinator?

    init(
      layoutCollection: any TextLayoutCollection = EmptyTextLayoutCollection(),
      coordinator: TextSelectionCoordinator? = nil
    ) {
      self.layoutCollection = layoutCollection
      setCoordinator(coordinator)
    }

    func setLayoutCollection(_ layoutCollection: any TextLayoutCollection) {
      guard !layoutCollection.isEqual(to: self.layoutCollection) else {
        return
      }

      let oldLayoutCollection = self.layoutCollection
      self.layoutCollection = layoutCollection

      guard
        let selectedRange,
        layoutCollection.needsPositionReconciliation(with: oldLayoutCollection)
      else {
        return
      }

      // Try to reconcile the selected text range
      self.selectedRange = layoutCollection.reconcileRange(
        selectedRange,
        from: oldLayoutCollection
      )
    }

    func setCoordinator(_ coordinator: TextSelectionCoordinator?) {
      if self.coordinator === coordinator {
        return
      }

      self.coordinator = coordinator
      coordinator?.register(self)
    }

    func url(for point: CGPoint) -> URL? {
      layoutCollection.url(for: point)
    }

    func layoutIndex(of layout: Text.Layout) -> Int? {
      layoutCollection.index(of: layout)
    }
  }

  extension TextSelectionModel {
    var hasText: Bool {
      layoutCollection.hasSelectionEnd
        ? layoutCollection.selectableEndPosition != nil
        : layoutCollection.stringLength > 0
    }

    var startPosition: TextPosition {
      layoutCollection.startPosition
    }

    var endPosition: TextPosition {
      layoutCollection.endPosition
    }

    func attributedText(in range: TextRange) -> NSAttributedString {
      layoutCollection.attributedText(in: range)
    }

    func text(in range: TextRange) -> String {
      attributedText(in: range).string
    }

    func position(from position: TextPosition, offset: Int) -> TextPosition? {
      layoutCollection.position(from: position, offset: offset)
    }

    func offset(from: TextPosition, to: TextPosition) -> Int {
      layoutCollection.characterIndex(at: to) - layoutCollection.characterIndex(at: from)
    }

    func firstRect(for range: TextRange) -> CGRect {
      layoutCollection.firstRect(for: range)
    }

    func caretRect(for position: TextPosition) -> CGRect {
      layoutCollection.caretRect(for: position)
    }

    func selectionRects(for range: TextRange) -> [TextSelectionRect] {
      layoutCollection.selectionRects(for: range)
    }

    func selectionRects(for range: TextRange, layout: Text.Layout) -> [TextSelectionRect] {
      layoutCollection.selectionRects(for: range, layout: layout)
    }

    func closestPosition(to point: CGPoint) -> TextPosition? {
      layoutCollection.closestPosition(to: point)
        .flatMap(layoutCollection.clampToSelectableContent)
    }

    func closestPosition(to point: CGPoint, within range: TextRange) -> TextPosition? {
      guard let position = closestPosition(to: point) else { return nil }
      if position <= range.start { return range.start }
      if position >= range.end { return range.end }
      return position
    }

    func isPositionAtBlockBoundary(_ position: TextPosition) -> Bool {
      layoutCollection.isPositionAtBlockBoundary(position)
        || (layoutCollection.layouts[position.indexPath.layout].selectionEndIndex != nil
          && position == layoutCollection.selectableEndPosition(in: position.indexPath.layout))
    }

    func positionAbove(_ position: TextPosition, anchor: TextPosition) -> TextPosition? {
      layoutCollection.positionAbove(position, anchor: anchor)
    }

    func positionBelow(_ position: TextPosition, anchor: TextPosition) -> TextPosition? {
      layoutCollection.positionBelow(position, anchor: anchor)
    }

    func characterRange(at point: CGPoint) -> TextRange? {
      guard let range = layoutCollection.characterRange(at: point) else {
        return nil
      }
      return layoutCollection.clampRange(range, layoutIndex: range.start.indexPath.layout)
    }

    func blockStart(for position: TextPosition) -> TextPosition? {
      layoutCollection.blockStart(for: position)
    }

    func blockEnd(for position: TextPosition) -> TextPosition? {
      layoutCollection.blockEnd(for: position)
    }

    func blockRange(for position: TextPosition) -> TextRange? {
      layoutCollection.blockRange(for: position)
    }

    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func wordRange(for position: TextPosition) -> TextRange? {
      guard let range = layoutCollection.wordRange(for: position) else {
        return nil
      }
      return layoutCollection.clampRange(range, layoutIndex: position.indexPath.layout)
    }

    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func nextWord(from position: TextPosition) -> TextPosition? {
      layoutCollection.nextWord(from: position)
        .flatMap(layoutCollection.clampToSelectableContent)
    }

    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func previousWord(from position: TextPosition) -> TextPosition? {
      layoutCollection.previousWord(from: position)
    }
  }
#endif
