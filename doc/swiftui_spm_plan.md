# SwiftUI & SPM Refactor Plan

## Goals
- Replace existing UIKit-based interface with SwiftUI equivalents.
- Extract Pure Data engine wrappers and drawing utilities into a reusable Swift Package.

## 1. Codebase Audit
- Review current UIKit view controllers in `src/` such as `StartViewController`, `PatchViewController`, and others.
- Map UI flows and features to identify SwiftUI View equivalents.
- Catalog Pure Data–specific code in `libs/pd`, `src/gui`, and related modules.

## 2. Swift Package Manager Library
1. Create `Packages/PdCore` with `Package.swift` defining at least two targets:
   - `PdCore`: low-level libpd bindings and audio session management.
   - `PdGraphics`: drawing and widget code currently in `src/gui`.
2. Move corresponding source files into `Sources/PdCore` and `Sources/PdGraphics`.
3. Provide public APIs for:
   - Initializing and running Pure Data patches.
   - Widget drawing primitives and geometry utilities.
4. Add unit tests for the new package where possible; include sample patches from `tests/`.
5. Update the main app target to depend on the new package via `Package.swift` or Xcode integration.

## 3. Transition to SwiftUI
1. Introduce a new SwiftUI `App` entry point replacing `UIApplicationMain` in `src/main.m`.
2. For each existing controller:
   - Build a SwiftUI `View` replicating current behavior.
   - Use `@State` and `@ObservedObject` to manage patch state and settings.
   - Replace navigation flows with `NavigationStack` or tab views.
3. Integrate `PdGraphics` widgets as SwiftUI `View` wrappers, leveraging `Canvas` or `CoreGraphics` as needed.
4. Replace storyboards and nibs with pure SwiftUI layout.
5. Migrate settings, browser, and patch screens iteratively while maintaining feature parity.

## 4. Testing & Validation
- Ensure existing patches in `tests/` render correctly through the new SwiftUI views.
- Provide unit tests for key library components using `swift test`.
- Use SwiftUI previews for rapid UI iteration.

## 5. Migration Strategy
- Maintain a compatibility layer so the legacy UIKit interface can run alongside new SwiftUI views during development.
- Gradually deprecate Objective-C sources once SwiftUI features reach parity.
- Document breaking changes and update the composer pack accordingly.

## 6. Documentation
- Update `README.md` and user guides to reflect SwiftUI requirements and package usage.
- Provide examples on integrating `PdCore` in other apps via SPM.

