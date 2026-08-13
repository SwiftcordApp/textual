import SwiftUI

/// Retains synchronously computed view output without invalidating the view that computed it.
///
/// This is useful when output must exist during the first layout pass. Using an initial
/// `onChange` to copy that output into `@State` schedules another SwiftUI graph update even
/// though the rendered value is unchanged.
@MainActor
final class ViewOutputCache<Key: Equatable, Output>: ObservableObject {
  private var entry: (key: Key, output: Output)?

  func output(for key: Key, create: () -> Output) -> Output {
    if let entry, entry.key == key {
      return entry.output
    }

    let output = create()
    entry = (key, output)
    return output
  }
}
