#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import UIKit

  final class TextRangeBox: UITextRange {
    private let _start: TextPositionBox
    private let _end: TextPositionBox

    var wrappedValue: TextRange {
      .init(start: _start.wrappedValue, end: _end.wrappedValue)
    }

    var wrappedStart: TextPosition {
      _start.wrappedValue
    }

    var wrappedEnd: TextPosition {
      _end.wrappedValue
    }

    override var start: UITextPosition { _start }
    override var end: UITextPosition { _end }

    override var description: String {
      "[\(_start)...\(_end)]"
    }

    override var isEmpty: Bool {
      _start.documentOffset == _end.documentOffset
    }

    override func isEqual(_ object: Any?) -> Bool {
      guard let other = object as? TextRangeBox else { return false }
      return _start.documentOffset == other._start.documentOffset
        && _end.documentOffset == other._end.documentOffset
    }

    override var hash: Int {
      var hasher = Hasher()
      hasher.combine(_start.documentOffset)
      hasher.combine(_end.documentOffset)
      return hasher.finalize()
    }

    init(start: TextPositionBox, end: TextPositionBox) {
      assert(
        start.wrappedValue <= end.wrappedValue,
        "[UITextRangeWrapper] start position must be <= end position"
      )

      self._start = start
      self._end = end
    }

    convenience init(from: TextPositionBox, to: TextPositionBox) {
      if from.documentOffset < to.documentOffset
        || (from.documentOffset == to.documentOffset && from.wrappedValue <= to.wrappedValue)
      {
        self.init(start: from, end: to)
      } else {
        self.init(start: to, end: from)
      }
    }

    convenience init(position: TextPositionBox) {
      self.init(start: position, end: position)
    }
  }
#endif
