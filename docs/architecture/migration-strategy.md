# Migration Strategy

## Approach

The rebuild was executed as a foundation-first migration.

1. Write source-of-truth docs and brand skill
2. Introduce centralized theme, routing, and provider architecture
3. Replace auth/session entry flow
4. Replace customer flow
5. Replace vendor flow
6. Verify with analysis and tests

## Why This Approach

- It prevents design drift during screen rewrites
- It fixes navigation quality at the shell level first
- It gives both customer and vendor flows the same systemized foundation
- It keeps mock data in place while upgrading the architecture

## Remaining Follow-Up Opportunities

- Expand repository layer to real Firestore-backed restaurant and vendor data
- Add more provider and routing tests
- Remove legacy prototype files that are no longer part of the active app path
- Add dark mode support once the light theme is fully validated
