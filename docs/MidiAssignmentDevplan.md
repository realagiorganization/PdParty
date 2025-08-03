# MIDI Assignment Page Development Plan

This document describes adding a dedicated **MIDI Assignment** page so hardware controllers can trigger core PdParty functions. The page exposes default mappings for patch navigation, playback, recording and volume, and lets users customize assignments.

## 1. Persisted mapping model

1. Define an enum of assignable actions (next patch, previous patch, play/pause, record, mic volume, etc.).
2. Create a `MidiMapping` structure storing message type, channel and data value for each action.
3. Add a `midiMappings` dictionary to `Defaults.plist` so default assignments load on first launch.
4. Implement a `MidiAssignmentManager` that loads/saves mappings and listens for MIDI events via `MidiBridge`.

## 2. MIDI Assignment Page UI

1. Add `MidiAssignmentViewController` as a table-based editor similar to the existing MIDI settings view.
2. Each row shows the action name and current mapping; tapping a row enters a learn mode that updates the mapping when the next MIDI message arrives.
3. Provide buttons to reset to defaults and import/export mappings.
4. Surface the page from the Settings or Tools menu.

## 3. Hook actions to the app

1. Integrate with `SceneManager` so assignments such as **Next Patch** or **Previous Patch** call `openScene` on the correct path.
2. Reuse control methods from `SceneControlsView` to toggle play/pause, start/stop recording and adjust mic volume.
3. Dispatch UI updates on the main thread to keep controls in sync when triggered from MIDI input.

## 4. Default mappings

1. Ship sensible defaults, e.g.:
   - CC20 → Previous Patch
   - CC21 → Next Patch
   - CC7  → Mic Volume
   - CC22 → Play/Pause
   - CC23 → Record
2. Document defaults in the assignment page and README.
3. Allow users to restore defaults at any time.

## 5. Testing strategy

1. Unit test serialization/deserialization of the mapping dictionary.
2. Integration tests simulate MIDI messages and verify the correct app actions fire.
3. Manual test with a physical controller: navigate patches, adjust volume and record to ensure mappings work.

## 6. Future enhancements

- Per-scene or per-patch override layers.
- Outgoing MIDI feedback so controllers can light LEDs or update displays when app state changes.
- Support for exporting/importing mappings as JSON files for sharing.
