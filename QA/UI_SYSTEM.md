# ChillFi UI system (app + website)

Derived from the values the existing screens already used most — not a redesign. Use these for any new or edited UI.

## Colour
| Role | App (`AppColors`) | Website (Tailwind) | Value |
|---|---|---|---|
| Brand orange (auth/onboarding CTAs app; primary CTAs web) | `primaryOrange` | `brand` / `hover:bg-brand-hover` | #FF6B2C / #E05520 |
| Accent purple (in-app primary buttons, active tab, links) | `secondaryPurple` | `accent` | #7B2CFF |
| Text | `darkText` | `ink` | #121212 app · #111827 web |
| Secondary text | `greyText` | `text-gray-400/500` | #8E8E93 |
| Border | `fieldBorder` | `line` | #E8E8E8 · #ECECEC |
| Page grey | `lightBackground` | `surface` / `bg-gray-50` | #FAFAFA · #F8F7FC |

App primary buttons are **purple**; orange gradients are reserved for onboarding/auth. Website primary buttons are **orange**.

## Typography (Poppins, bundled in the app; 400–900 loaded on the web)
App roles (`AppText`, lib/core/theme/app_theme.dart): display 26/w700 (auth titles) · pageTitle 18/w700 (every AppBar and custom header) · pageSubtitle 12 · sectionTitle 16/w700 · cardTitle 14/w600 · body 14 · bodySmall 12 · label 12/w600 · caption 11 · button 16/w700.
Website: page `h1` = `text-3xl font-black text-[#111827]` (one per page); section `h2` = `text-2xl font-black`; subtitle `text-sm font-bold text-gray-400`.

## Spacing / shape / size
Spacing `AppSpace`: 4 · 8 · 12 · 16 · 24 · 32; page gutter 20 (regular) / 24 (auth & full-bleed). Website: `Container` (`px-4 md:px-6 lg:px-10`, max 1440) + `py-10` page padding.
Radius `AppRadius`: 8 chips · 12 inputs/small cards · 16 buttons/cards · 20 dialogs · 24 sheets. Website: `rounded-xl` controls, `rounded-2xl`/`[24px]` cards.
Sizes `AppSize`: button 56 · input 56 · back button 40 (44 touch target).

## Shared components
App: `AppBackButton` (every in-app header), `AuthLogo` + `AuthBackButton` (auth flow; logo is a shared Hero), `AppErrorDialog`, `AppErrorState`, `GuestPrompt`, `addToCartWithFeedback`.
Website: `Container`, `Breadcrumb`, `showErrorDialog`, `Loader2` spinner (brand orange).

## Motion (one vocabulary)
| Event | App | Website |
|---|---|---|
| Forward navigation | `ChillFiPageTransitionsBuilder`: new screen slides 12% from the right + fades in, old drifts 6% left — 320 ms easeOutCubic | content `animate-page-in` (fade + 6px rise, 240 ms) under a steady header; scroll to top |
| Back | exact reverse (280 ms) | browser back — same enter animation |
| Tab switch | `TabSwitchRoute` cross-fade 250 ms over the current tab (Home stays underneath) | — |
| In-screen entrance | ≤ 380 ms (`AppMotion.content`), runs with the page transition, never after it | — |
| Press | Material ink ripple | `active:scale-[0.98]` on primary buttons |
| Anchor | auth logo Hero keeps its place Login → Signup → OTP → Notifications | header never animates |

iOS keeps the native Cupertino transition (edge-swipe back). The website honours `prefers-reduced-motion`.

## Accessibility
Back buttons are labelled and 44px; website has a visible `:focus-visible` ring on every interactive element.
