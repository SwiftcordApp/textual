#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import UIKit

  final class TextPositionBox: UITextPosition {
    let wrappedValue: TextPosition
    /// The UTF-16 offset UIKit uses as the position's identity.
    let documentOffset: Int

    override var description: String {
      wrappedValue.description
    }

    override func isEqual(_ object: Any?) -> Bool {
      documentOffset == (object as? TextPositionBox)?.documentOffset
    }

    override var hash: Int {
      documentOffset.hashValue
    }

    init(_ wrappedValue: TextPosition, documentOffset: Int) {
      self.wrappedValue = wrappedValue
      self.documentOffset = documentOffset
    }
  }
#endif
