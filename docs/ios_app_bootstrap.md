# realagiorganization/ios_app Bootstrap

This repo needs to live alongside `PdParty` in the workspace. The bare repository has been cloned (it is currently empty upstream) using the existing automation token:

```bash
cd /app/workspace/repos
git clone https://x-access-token:${GITHUB_PAT}@github.com/realagiorganization/ios_app.git realagiorganization__ios_app
```

where `${GITHUB_PAT}` is the automation token already configured in `.git/config` for PdParty. The working tree now lives at `/app/workspace/repos/realagiorganization__ios_app`.

## Submodules

The upstream repository does not define any submodules yet. When submodules are added, they can be initialized with:

```bash
git submodule update --init --recursive
```

PdParty itself has already been brought up-to-date with that command so that its `libs/pd` dependency (and nested modules) are ready for reuse.

## Development Environment Expectations

Because an iOS application requires a macOS toolchain, the following environment should be prepared on the target development machine:

1. **Xcode & Command Line Tools** – Install Xcode 15+ from the App Store and run `xcode-select --install` to make the CLI tools available.
2. **CocoaPods & Bundler** – `sudo gem install cocoapods bundler` so that the project can manage Swift/Objective‑C dependencies and automation scripts when they land.
3. **Homebrew Utilities** – Install [Homebrew](https://brew.sh) and add any common requirements: `brew install node git-lfs cmake`.
4. **Node.js Tooling** – `nvm install --lts` (or install node via Homebrew) for any JavaScript-based tooling (Fastlane plugins, linting helpers, etc.).
5. **Fastlane** – Once Bundler is present, run `bundle init` inside the repo and add `fastlane`, or simply `sudo gem install fastlane` if a system install is acceptable.

After the repository receives its initial sources you can run the usual bootstrapping commands from within `/app/workspace/repos/realagiorganization__ios_app`:

```bash
bundle install        # sets up fastlane and any Ruby-side automation
npm install           # installs JS/TS toolchains if package.json is added
pod install           # resolves Xcode workspace dependencies
```

## Next Steps

With the clone available and the PdParty submodules initialized, future commits can start populating `ios_app` with project files. Once those exist, rerun the commands above to pull tool dependencies so the app builds cleanly.

## Automation notes

- Cloned `realagiorganization/ios_app` into `/app/workspace/repos/realagiorganization__ios_app` for this run and confirmed no upstream submodules yet.
- Refreshed PdParty submodules (`libs/pd`, `pure-data`, `opensl_stream`) so shared dependencies are populated locally.
- macOS-only tooling (Xcode, CocoaPods, Homebrew) cannot be installed in this Linux container; follow the setup steps above on a macOS host.
