# iOS Build and Distribution Reporting Plan

Goal: produce reliable reports for both `xcodebuild` output and App Store/TestFlight uploads by running on a macOS builder (GitHub-hosted or an external macOS runner). This keeps us unblocked regardless of which macOS capacity we end up using.

## Current State
- Workflow `.github/workflows/ios-deploy.yml` runs on `macos-latest`, installs Ruby/bundle, and calls `fastlane deploy` (screenshots → `build_app` → `upload_to_testflight`). Artifacts are only screenshots; no `xcodebuild` logs/results are retained.
- Fastlane lane assumes `APP_STORE_CONNECT_API_KEY` is provided but does not explicitly manage signing assets, export options, or result bundles.

## Option A: GitHub Actions on macOS (recommended baseline)
1. **Required secrets**:  
   - `APP_STORE_CONNECT_API_KEY` (App Store Connect API key JSON).  
   - Signing: either `MATCH_PASSWORD` + `MATCH_GIT_URL` (preferred) or `DISTRIBUTION_CERT_BASE64`/`DISTRIBUTION_CERT_PASSWORD` and `PROVISIONING_PROFILE_BASE64`.  
   - Optional: `SLACK_WEBHOOK_URL` for notifications.
2. **Workflow shape** (two dependent jobs so we can cache logs even if upload fails):
   ```yaml
   name: iOS Build + TestFlight
   on:
     workflow_dispatch:
     push:
       branches: [ main ]
   jobs:
     build-report:
       runs-on: macos-latest # switch to self-hosted label if needed
       steps:
         - uses: actions/checkout@v4
         - uses: ruby/setup-ruby@v1
           with:
             ruby-version: '3.1'
             bundler-cache: true
         - name: Install dependencies
           run: bundle install
         - name: Build (archive) with reports
           run: |
             mkdir -p build/reports
             xcodebuild -scheme PdParty -configuration Release \
               -destination 'generic/platform=iOS' \
               -archivePath build/PdParty.xcarchive \
               -resultBundlePath build/PdParty.xcresult \
               clean archive | xcpretty -r junit -o build/reports/xcodebuild-junit.xml
         - name: Export IPA
           run: |
             /usr/libexec/PlistBuddy -c "Add :method string app-store" exportOptions.plist || true
             xcodebuild -exportArchive -archivePath build/PdParty.xcarchive \
               -exportPath build/export \
               -exportOptionsPlist exportOptions.plist
         - uses: actions/upload-artifact@v4
           with:
             name: ios-build-report
             path: |
               build/PdParty.xcresult
               build/reports
               build/export/*.ipa
     testflight-upload:
       needs: build-report
       runs-on: macos-latest
       steps:
         - uses: actions/checkout@v4
         - uses: ruby/setup-ruby@v1
           with:
             ruby-version: '3.1'
             bundler-cache: true
         - uses: actions/download-artifact@v4
           with:
             name: ios-build-report
         - name: Fastlane upload
           env:
             APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
           run: |
             bundle exec fastlane pilot upload --ipa build/export/*.ipa --skip_waiting_for_build_processing true
   ```
   - If we prefer to keep the lane, replace the `pilot upload` step with `bundle exec fastlane deploy --skip_screenshots`.
   - Artifacts now include `.xcresult` (for Xcode UI logs/metrics), JUnit log for CI visibility, and the generated IPA.
3. **Notes**:
   - Pin `macos-13` or `macos-14` if Xcode version needs stability.
   - Add `workflow_dispatch` for manual TestFlight pushes without waiting for main-branch merges.
   - If signing via match, add a setup step: `bundle exec fastlane match appstore --readonly`.

## Option B: External macOS Builder / Self-hosted Runner
- Install a self-hosted runner on the macOS build machine and label it (e.g., `self-hosted`, `macos`, `xcode15`); point the workflow `runs-on` to those labels.
- Mirror the same script as Option A so artifacts and behavior stay identical.
- Keep signing assets local to the builder if corporate policy forbids uploading to GitHub Secrets; export them to the runner’s keychain before jobs.
- If integration must happen outside Actions, schedule a webhook-triggered script on the builder that:
  1. Pulls the repo at the requested ref.
  2. Runs the `xcodebuild` archive command above with `-resultBundlePath`.
  3. Runs `fastlane pilot upload` (or `fastlane deploy`) with the stored API key.
  4. Pushes `build/export/*.ipa`, `build/reports`, and `*.xcresult` to artifact storage (S3/Artifactory) and posts the links back to GitHub via a commit status or issue comment.

## Near-Term Actions
1. Implement the two-job workflow (or refactor `ios-deploy.yml`) so builds always emit `.xcresult`, JUnit, and IPA artifacts, and uploads depend on build success.
2. Decide on signing strategy (`match` vs. raw cert/profile) and populate the required secrets; add a short `docs/ci-secrets.md` if the team needs a checklist.
3. For the external builder path, register and label a self-hosted runner, then run the same workflow there to validate Xcode compatibility before enabling TestFlight uploads from it.
