#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  struct EmptyTextLayoutCollection: TextLayoutCollection {
    var layouts: [any TextLayout] {
      []
    }

    func isEqual(to other: any TextLayoutCollection) -> Bool {
      other.layouts.isEmpty
    }

    func needsPositionReconciliation(with other: any TextLayoutCollection) -> Bool {
      !other.layouts.isEmpty
    }

    func index(of layout: Text.Layout) -> Int? {
      nil
    }
  }
#endif
