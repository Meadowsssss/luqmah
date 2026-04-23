# Luqmah Brand Guidelines Spec

## Overview

Luqmah is a campus-first food ordering product for Hashemite University students. The brand should feel practical, warm, dependable, and clear. It should not read like a generic delivery clone, an overly playful consumer startup, or a cold enterprise dashboard.

This document is the source of truth for Luqmah's product design language and the basis for the `luqma-brand-guidelines` skill and Flutter theme system.

## Brand Principles

1. Utility first
   Luqmah should help users complete food and vendor tasks quickly and confidently.
2. Warmth without noise
   The product should feel human and welcoming, but never cluttered or over-decorated.
3. Same brand across roles
   Customer and vendor surfaces should share one visual language.
4. Calm confidence
   Interfaces should feel stable, readable, and predictable.
5. Campus familiarity
   The app should feel grounded in student life and day-to-day campus use.

## Voice And Copy

- Tone: warm and concise
- Writing style: direct, supportive, low-friction
- Avoid: slang-heavy copy, hyper-promotional marketing, corporate jargon
- Preferred patterns:
  - "Browse campus favourites"
  - "Ready for pickup"
  - "Add to cart"
  - "No active orders right now"

## Color System

### Core Palette

- `#15343A` primary deep green
- `#214D4A` secondary deep green
- `#FF6B57` warm coral accent
- `#F6F7F9` app background
- `#FFFFFF` primary surface
- `#EFF3F3` secondary surface
- `#122429` darkest text/shell surface
- `#5F6B70` muted text
- `#D8E0E1` borders and dividers

### Semantic Colors

- Success: `#1D8F55`
- Warning: `#C97A10`
- Info: `#0C87A8`
- Error: `#C2483C`

### Usage Rules

- Deep green is the structural brand anchor.
- Warm coral is the main highlight and action accent.
- Light neutrals carry most screens and content surfaces.
- Do not introduce additional greens for separate roles unless a semantic state requires it.
- Customer and vendor screens share the same palette.

## Typography

- Style direction: modern sans
- Primary font stack in Flutter: system sans fallback chain
- Headings: strong weight, tight hierarchy, compact spacing
- Body text: comfortable, readable, neutral
- Labels: concise, slightly stronger than body

### Scale Guidance

- Display / hero: 28-32
- Page title: 22-28
- Section title: 18-20
- Body: 14-16
- Support / helper: 12-13
- Small badges and chips: 11-12

## Spacing, Shape, And Elevation

### Spacing Scale

- 4, 8, 12, 16, 20, 24, 32

### Radius Scale

- 12: small interactive elements
- 16: inputs, chips, compact cards
- 20: standard cards
- 24: prominent surfaces
- 28+: hero containers and standout shells

### Elevation

- Soft shadows only
- Prefer low-contrast shadow layers
- Do not stack heavy shadows and high-contrast borders on the same component

## Component Direction

### Buttons

- Primary buttons use deep green backgrounds with light foreground text
- Accent buttons may use warm coral for emphasis-heavy moments
- Outline buttons should feel light and precise, never heavy

### Cards

- White or near-white surfaces
- Rounded corners
- Gentle shadow
- Strong content hierarchy
- Structured imagery with reliable fallback behavior

### Inputs

- Filled neutral surfaces
- Rounded and soft
- Clear labels and validation states

### Navigation

- Bottom navigation should feel persistent and stable
- Switching should preserve state and avoid page reconstruction churn
- Active state should be obvious but restrained

### Chips And Segmented Controls

- Use for filters, categories, and sub-views
- Prefer subtle selected backgrounds with clear label contrast

## Motion

- Motion should be subtle and smooth
- Use restrained easing and short durations
- Preserve perceived stability during tab switches and route transitions
- Avoid decorative animations that do not support task completion

### Suggested Motion Tokens

- Fast: 160ms
- Standard: 220ms
- Slow: 320ms

## Imagery

- Food photography supports utility and appetite, but must not dominate information layout
- Use consistent crop ratios
- Avoid noisy overlays over photos
- Provide graceful placeholders for missing or broken images

## Accessibility

- Minimum target: WCAG AA
- Ensure readable contrast on all core surfaces
- Maintain touch-friendly targets
- Do not rely on color alone for critical states
- Preserve readable hierarchy in both customer and vendor flows

## Vendor Surface Guidance

- Vendor UI uses the same brand system as customer UI
- Vendor screens may be denser, but should not look like a separate brand
- Operational states should rely on semantic colors, not alternate brand palettes

## Design Anti-Patterns

- Hardcoded one-off colors for individual screens
- Unrelated visual languages between customer and vendor views
- Oversized imagery that weakens task clarity
- Decorative gradients without purpose
- Heavy corporate dashboard styling
- Overly cute or food-mascot driven UI

## Flutter Implementation Rules

- Centralize all tokens in theme files and theme extensions
- Consume semantic colors instead of raw color literals in screens
- Shared components should derive shape, spacing, and color from the central design system
- Avoid screen-level custom styling unless there is a concrete product reason
