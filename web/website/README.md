# ChillFi Website Architecture

This folder contains the complete architecture for the ChillFi web platform, designed to mirror the existing Flutter mobile application.

## Folder Structure

- **assets/**: All static media (images, icons, logos, etc.).
- **components/**: Atomic UI components (Buttons, Cards, Inputs) categorized by feature.
- **layouts/**: High-level page wrappers (Main, Auth, Admin).
- **pages/**: Route-level components for all 27+ required views.
- **sections/**: Reusable page blocks (Hero, Testimonials, Flash Sales).
- **styles/**: Global CSS, typography tokens, and utility classes.
- **theme/**: Design tokens (Colors, Spacing, Breakpoints) following the Flutter app's design system.
- **hooks/**: Custom logic for responsiveness, theme switching, and data handling.
- **utils/**: Pure helper functions and validators.
- **design-system/**: Documented UI components and base primitives.

## Design Guidelines

- **Primary Color**: #FF6B2C (Primary Orange)
- **Secondary Color**: #7B2CFF (Secondary Purple)
- **Font Family**: Poppins
- **Radius**: 20px (Primary), 12px (Secondary)

## Implementation Roadmap

1. **Phase 1**: Initialize Design Tokens and Base Typography in `theme/` and `styles/`.
2. **Phase 2**: Create common components in `design-system/` (Buttons, Inputs).
3. **Phase 3**: Develop `layouts/` and `sections/` (Navigation, Footer).
4. **Phase 4**: Build functional `pages/` using placeholder data from `utils/mockData`.
5. **Phase 5**: Apply `responsive/` overrides for Tablet and Desktop views.
