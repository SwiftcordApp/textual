import Foundation

extension AttributedString.Runs.Run {
  var isTextualPreformatted: Bool {
    if self.inlinePresentationIntent?.isPreformatted ?? false {
      return true
    }

    if self.presentationIntent?.isPreformatted ?? false {
      return true
    }

    return false
  }
}

private extension InlinePresentationIntent {
  var isPreformatted: Bool {
    contains(.code) || contains(.inlineHTML) || contains(.blockHTML)
  }
}

private extension PresentationIntent {
  var isPreformatted: Bool {
    components.first?.kind.isPreformatted ?? false
  }
}

private extension PresentationIntent.Kind {
  var isPreformatted: Bool {
    switch self {
    case .codeBlock:
      return true
    default:
      return false
    }
  }
}
