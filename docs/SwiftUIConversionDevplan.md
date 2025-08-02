# SwiftUI Conversion Development Plan

This document describes a step-by-step plan for augmenting **PatchViewController** with a SwiftUI-powered chat bubble interface so users can instruct an AI agent to edit Pure Data patches.  The goal is to minimize custom code by relying on popular open‑source packages.

## 1. Dependencies

Use the Swift Package Manager (SPM) to integrate third-party libraries.

| Purpose | Package | URL |
|---------|---------|-----|
| Message bubbles and input field | Exyte `Chat` | `https://github.com/exyte/Chat` |
| OpenAI network wrapper | `OpenAISwift` | `https://github.com/adamrushy/OpenAISwift` |

Steps:
1. In Xcode, open **PdParty.xcodeproj**.
2. Select *File ▸ Add Packages…*
3. Add the package URLs above and keep the default "Up to Next Major" version rules.

## 2. Build the SwiftUI chat view

1. Create `AIChatView.swift` in the iOS target.
2. Import `Chat` and define `@State var messages: [Message] = []`.
3. Use `ChatView` from the package to display the `messages` array and an input bar.
4. When the user taps **Send**, append a new `Message` with the user's text and call a `sendToAI()` helper.

```swift
struct AIChatView: View {
    @State private var messages: [Message] = []
    var body: some View {
        ChatView(messages: messages) { draft in
            sendToAI(draft.text)
        }
    }
}
```

## 3. Send and receive AI messages

1. Configure `OpenAISwift` with an API key at app launch.
2. Implement `sendToAI(_:)` to call `openAI.sendCompletion`.
3. Convert the completion text into a `Message` from the assistant and append it to `messages`.
4. Errors should insert a message describing the issue so the chat stays informative.

## 4. Forward patch-editing instructions

1. Declare a protocol `AIInstructionDelegate` with methods such as `func applyInstruction(_ text: String)`.
2. Give `AIChatView` a `delegate` closure or object conforming to the protocol.
3. When an AI reply contains an instruction (e.g., lines prefixed with `edit:`), forward the text to the delegate.
4. `PatchViewController` implements the protocol to handle patch manipulations (open files, edit controls, etc.).

## 5. Bridge SwiftUI with UIKit

1. Create `AIChatViewController` that stores an instance of `AIChatView`.
2. Wrap `AIChatView` with `UIHostingController` and add it as a child controller.
3. Provide show/hide functionality (e.g., a toolbar button that slides the chat over the patch area).
4. Ensure Auto Layout constraints keep the patch visible while the chat is open.

## 6. Optional enhancements

- Persist `messages` using `@AppStorage` or a lightweight file to restore conversations.
- Use `Combine` publishers from `OpenAISwift` for streaming tokens.
- Swap `Chat` for `StreamChatSwiftUI` if features like channels or reactions are desired.
- Add basic markdown rendering for AI replies using libraries like `MarkdownUI`.

## 7. Testing strategy

- Unit test `AIChatView` logic with `XCTest` to ensure messages append correctly.
- Mock `OpenAISwift` responses for predictable tests.
- UI tests can verify that the chat controller appears and forwards instructions to `PatchViewController`.
- Manual run-through: open a patch, send a message, confirm AI response, and observe patch edits.

This plan leverages existing SwiftUI packages and minimal bridging code to add an AI-assisted chat interface to the patch viewer.
