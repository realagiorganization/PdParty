# AudioUnit Plug-in Development Plan for PdParty

## Overview
PdParty currently runs Pure Data patches inside a standalone iOS app. The goal is to turn this application into an AUv3 plug‑in that exposes the same UI and the same audio/MIDI behavior to any AudioUnit host. The plan below outlines the steps required to refactor the existing codebase, add an AUv3 extension, and test the result in common hosts.

## Phase 0 – Research & Requirements
1. **Audit PdParty architecture**
   - Document how `PdAudioController`, `PatchViewController`, and libpd interact.
   - Identify external dependencies and ensure they can run inside an AUv3 sandbox.
2. **Study AudioKit Synth One**
   - Review `S1AudioUnit`, `DSPKernelAdapter`, and `BufferedOutputBus` for patterns.
   - Note how MIDI events and UI updates are routed between the plug‑in and host.
3. **Define plug‑in capabilities**
   - Decide on audio layout (mono/stereo), MIDI input, optional MIDI output.
   - Choose plug‑in type: instrument (`musicDevice`) or effect (`audioEffect`).

## Phase 1 – Core Audio Unit Implementation
1. **Create PdAudioUnit**
   - Subclass `AUAudioUnit` and mirror Synth One’s structure.
   - Wrap libpd in a C++/Objective‑C DSP kernel with methods `prepare`, `process`, `setParameter`, and `getParameter`.
   - Use `BufferedOutputBus` to manage multi‑channel audio buffers.
2. **Render loop**
   - Implement `allocateRenderResources` and the `renderBlock` that calls libpd’s audio processing.
   - Handle sample‑rate changes, buffer size negotiation, and host tempo info.
3. **Parameter tree**
   - Expose parameters for volume, patch switching, and any Pd controls needed by the host.
   - Implement `AUParameterTree` so hosts can automate these values.
4. **State management**
   - Support `fullState` saving/restoration for host session recall by serializing the loaded patch and parameter values.

## Phase 2 – AUv3 Extension Target
1. **Add new Xcode target**
   - Create an “Audio Unit Extension” target inside `PdParty.xcodeproj`.
   - Configure `Info.plist` with `AudioComponentFactoryFunction`, `AudioComponentDescription`, and supported channel layouts.
2. **Build settings**
   - Enable Objective‑C++ for files that bridge to the Pd DSP kernel.
   - Ensure the extension links to libpd and required system frameworks.
3. **App sandbox**
   - Audit file access; move patch resources into the shared `App Group` container if needed.

## Phase 3 – User Interface Integration
1. **Reuse PatchViewController**
   - Make `PatchViewController` conform to `AUAudioUnitFactory` and `AUViewController` requirements.
   - Instantiate `PdAudioUnit` within the view controller and wire up UI elements.
2. **Host presentation**
   - Ensure the view controller’s layout works within varying host window sizes.
   - Test that multiple instances can present their UIs independently.
3. **Preset handling**
   - Map PdParty’s existing preset system to the AUv3 `AUAudioUnitPreset` API.

## Phase 4 – MIDI and Event Routing
1. **MIDI input**
   - Implement `scheduleMIDIEventBlock` so hosts can send MIDI messages into the Pd engine.
   - Translate incoming MIDI to Pd symbols/messages according to PdParty’s convention.
2. **MIDI output (optional)**
   - Provide a mechanism for Pd patches to send MIDI back to the host using `AUMIDIOutputEventBlock`.
3. **Inter‑thread communication**
   - Mirror Synth One’s helpers (`NoteNumber`, `PlayingNotes`, `DependentParameter`) to keep audio and UI threads in sync.

## Phase 5 – Testing & Optimization
1. **Unit tests**
   - Add test harnesses that load simple Pd patches and verify audio/MIDI processing using `AVAudioEngine`.
2. **Host compatibility**
   - Manually test in GarageBand, AUM, and other AUv3 hosts for UI presentation, automation, and preset recall.
3. **Performance tuning**
   - Profile CPU/memory usage; ensure the render loop meets real‑time constraints.

## Phase 6 – Documentation & Distribution
1. **Developer documentation**
   - Document the AUv3 architecture, build steps, and API for Pd patches to interact with the host.
2. **Sample patches**
   - Provide example Pd patches demonstrating audio I/O, MIDI control, and automation.
3. **App Store submission**
   - Update the main app’s `Info.plist` and entitlements to include the AUv3 extension.
   - Follow Apple’s guidelines for distributing Audio Unit extensions.

## Milestones & Timeline
| Milestone | Description | Estimated Time |
|-----------|-------------|----------------|
| 1 | Research & architecture audit | 1–2 weeks |
| 2 | Implement `PdAudioUnit` core | 2–3 weeks |
| 3 | AUv3 extension target + build | 1 week |
| 4 | UI integration & preset system | 2 weeks |
| 5 | MIDI routing & automation | 1–2 weeks |
| 6 | Testing across hosts | 2 weeks |
| 7 | Documentation & release prep | 1 week |

## Risks & Mitigations
- **Real‑time performance**: libpd must process within the host’s buffer deadlines. Mitigate by profiling and using vectorized operations where possible.
- **Sandbox file access**: AUv3 extensions have limited filesystem access. Use `App Group` containers and `UIDocumentPicker` for user files.
- **UI complexity**: Existing PdParty UI may require adjustments for small host windows. Consider responsive layout and minimalistic control pages.
- **Missing features**: Some PdParty modules (e.g., sensors, OSC) may not make sense inside a plug‑in. Document which features are unsupported.

## Outcome
Following this plan will yield an AUv3 plug‑in that embeds PdParty’s Pure Data engine and UI, allowing patches to run inside any host that supports Audio Units while retaining audio/MIDI interoperability and user customization.

