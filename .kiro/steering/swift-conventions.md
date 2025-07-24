# Swift Code Conventions

## File Organization
- Use MARK comments to organize code sections
- Group related properties and methods together
- Keep view models as @MainActor classes

## Naming
- Use descriptive property names (e.g., `savedNotes`, `currentStreak`)
- Enum cases use camelCase, raw values use proper case
- View file names end with "View.swift"

## SwiftUI Patterns
- Use @Published for observable properties
- Prefer @AppStorage for simple persistence
- Keep views focused and extract components when needed
- Use computed properties for derived state

## Code Style
- No verbose implementations
- Minimal file structure
- Extract reusable components only when actually reused