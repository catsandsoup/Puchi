# Project Constraints

## Keep It Small
- No unnecessary files or folders
- Avoid over-engineering solutions
- Don't create abstractions until actually needed
- Single responsibility per file when possible

## iOS App Specific
- Target iOS with SwiftUI
- Use native iOS patterns and conventions
- Leverage system frameworks (CoreLocation, AVKit, etc.)
- Follow Apple's Human Interface Guidelines

## Development Approach
- Be concise, not verbose
- Focus on working solutions over perfect architecture
- Test core functionality, don't over-test
- Keep dependencies minimal

## App Store Readiness
- All user data must stay local (no server dependencies)
- Proper error handling for all user-facing operations
- Graceful degradation when permissions denied
- Memory management for media files
- Crash prevention through validation
- Privacy policy compliance