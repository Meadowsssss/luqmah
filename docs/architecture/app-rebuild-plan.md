# Luqmah App Rebuild Plan

## Goal

Rebuild Luqmah on top of a centralized design system, Riverpod state management, and declarative routing using `go_router`, while preserving the core product intent and replacing weak prototype architecture.

## Target Outcomes

- One centralized Luqmah theme system
- One consistent brand language across customer and vendor flows
- Persistent app-shell navigation with smooth tab switching
- Repository-based data access with mock implementations first
- Provider-driven session, auth, cart, restaurants, and vendor state
- Clear feature-first structure that scales beyond the prototype

## Architecture Decisions

### State Management

- Use `flutter_riverpod`
- Replace global mutable static state with providers and notifiers
- Move async session identity, cart, restaurant data, and vendor data into provider-backed application state

### Routing

- Use `go_router`
- Centralize redirects based on authentication, verification, role, and vendor demo state
- Use persistent shell routes for customer and vendor navigation to avoid janky route replacement

### Data Access

- Introduce repository interfaces
- Keep local and mock data behind repositories for now
- Preserve a clean seam for future Firebase-backed data

### Theming

- Introduce centralized theme tokens and component themes
- Use Flutter `ThemeData` plus Luqmah-specific `ThemeExtension`s
- Remove direct color literals from most feature UIs

## Folder Direction

```text
lib/
  app/
    app.dart
    router/
    theme/
    shell/
  core/
    models/
    utils/
    extensions/
  features/
    auth/
    session/
    customer/
    vendor/
  shared/
    widgets/
    providers/
    repositories/
```

## Implementation Stages

### Stage 1: Planning And Source Of Truth

- Write brand guidelines
- Write audit and migration docs
- Create `luqma-brand-guidelines` skill
- Start operations log and staged checklist

### Stage 2: Foundation

- Add Riverpod and `go_router`
- Replace app bootstrap
- Create centralized theme and tokens
- Establish app router and shell routes

### Stage 3: Session And Auth

- Move session handling to providers
- Rebuild auth screens on the new theme system
- Centralize router redirects

### Stage 4: Customer Flow

- Rebuild restaurant list
- Rebuild restaurant menu
- Rebuild cart
- Rebuild customer settings
- Move cart logic to stable ID-based state

### Stage 5: Vendor Flow

- Rebuild vendor shell and tabs
- Rebuild orders, details, and product management views
- Align vendor screens to the same Luqmah brand system

### Stage 6: Hardening

- Remove stale code and weak patterns
- Improve tests
- Run `flutter analyze` and `flutter test`
- Fix accessibility and consistency issues

## Routing Model

- `/login`
- `/register`
- `/verify-email`
- customer shell
  - `/restaurants`
  - `/cart`
  - `/settings`
- drill-in customer routes
  - `/restaurants/:restaurantId`
- vendor shell
  - `/vendor/orders`
  - `/vendor/products`
  - `/vendor/insights`
  - `/vendor/profile`
- drill-in vendor routes
  - `/vendor/orders/:orderId`

## Persistence Strategy

- Keep Firebase Auth for authentication
- Keep vendor demo mode and role mapping via local preferences for now
- Keep restaurant and vendor data mocked behind repositories until backend expansion

## Technical Cleanup Goals

- Replace `ValueNotifier` service singletons
- Replace `Navigator.pushReplacement` tab switching
- Replace `Map<MenuItem, int>` cart keys with ID-based line items
- Replace widget-owned async identity fetching with providers
- Remove dead or transitional UI code not used by the rebuilt app
