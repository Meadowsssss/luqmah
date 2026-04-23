# Rebuild Log

## 2026-04-23

### Planned Direction

- Rebuild Luqmah around a centralized design system
- Replace imperative navigation with `go_router`
- Replace static app state patterns with Riverpod providers
- Unify customer and vendor UI under one Luqmah brand system
- Keep mock data behind repository interfaces for now

### Work In Progress

- Writing planning artifacts and the Luqmah brand skill
- Preparing the app foundation rewrite

### Completed Implementation

- Added centralized Luqmah theme tokens and component themes
- Replaced root app wiring with Riverpod and `go_router`
- Introduced persistent customer and vendor shells
- Rebuilt auth, customer, and vendor active flows on the new system
- Added mock-backed Riverpod state for cart, restaurants, and vendor data
- Updated tests to target the rebuilt app
- Removed legacy pages, widgets, and service singletons that were replaced by the new architecture
- Added persistent demo customer order history backed by local storage
- Wired demo checkout into vendor incoming orders and customer order history
- Replaced vendor insights placeholder with analytics cards driven by live mock state
- Expanded tests to cover repository persistence and vendor insights behavior

### Verification

- `flutter analyze`: passed
- `flutter test`: passed
- `flutter build web`: passed
