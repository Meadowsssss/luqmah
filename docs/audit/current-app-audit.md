# Current App Audit

## Summary

The current app is a capable prototype with clear customer and vendor flows, but the implementation is not ready to scale. The largest issues are architecture drift, duplicated visual decisions, imperative navigation, and global mutable UI state.

## High-Severity Issues

### 1. Navigation is scattered and imperative

- `Navigator.push`, `pushReplacement`, and `pushAndRemoveUntil` are used directly across pages.
- Vendor bottom navigation is implemented by replacing pages rather than preserving tab state.
- This causes janky transitions and poor state retention.

### 2. Theme is not centralized in practice

- A root `ThemeData` exists, but most real styling is implemented through screen-level color literals and custom decorations.
- Customer and vendor flows do not consistently share one palette.

### 3. Global mutable state is overused

- `AppSessionService`, `CartService`, and `VendorStore` hold app state through static fields.
- This is hard to test, hard to evolve, and weakly reactive.

### 4. Business logic is mixed into widgets

- Auth, session routing, filtering, and operational state transitions are largely widget-owned.
- UI and state management boundaries are weak.

## Medium-Severity Issues

### 5. Data strategy is inconsistent

- Firebase is used for auth, but restaurant and vendor data are local mocks.
- There is no repository abstraction to separate UI from data sources.

### 6. Cart model is fragile

- Cart state uses `Map<MenuItem, int>`.
- `MenuItem` has no equality override, which makes the approach brittle once data becomes non-local.

### 7. Session identity fetching is inefficient

- Shared widgets resolve identity through asynchronous widget rebuilds instead of stable app state.

### 8. Vendor access protection is weakly reactive

- Access checks read static role values directly instead of observing a proper source of truth.

### 9. UI duplication is high

- Forms, cards, chips, buttons, and surface patterns are repeated without a systemized component layer.

## Low-Severity Issues

### 10. Transitional or stale artifacts remain

- Template package naming remains in `pubspec.yaml`.
- A debug Firestore printer is still in `main.dart`.
- Some widgets appear likely unused in the current app shape.

### 11. Tests are very thin

- Coverage is not strong enough to protect a rewrite.

## Refactor Priorities

1. Theme and token centralization
2. Router and app-shell replacement
3. Riverpod state architecture
4. Cart and repository redesign
5. Customer flow rewrite
6. Vendor flow rewrite
7. Test coverage and cleanup
