# Rumie Redesign Spec
**Date:** 2026-06-23
**Status:** Approved for implementation

---

## Overview

Full visual redesign of the Rumie Flutter app using a **Brutalist Editorial** aesthetic. No swipe mechanic — replaced with a vertical scroll feed. Dual light/dark theme. New value scoring feature on listings.

---

## Design System

### Aesthetic
Brutalist Editorial: oversized Syne type, cream/black base, solid borders, structured stat grids, uppercase chip labels. No gradients on UI elements. No glassmorphism. No rounded pill buttons. Typography is the design.

### Fonts
- **Headings:** `Syne` 800 weight — names, screen titles, prices, key numbers
- **Body/UI:** `Inter` 500–700 — labels, descriptions, buttons, metadata

### Color Tokens

| Token | Light | Dark |
|-------|-------|------|
| `bg` | `#F2F0EB` | `#0D0B0A` |
| `surface` | `#FFFFFF` | `#1A1710` |
| `text` | `#1A1A1A` | `#F2F0EB` |
| `textSecondary` | `#888888` | `rgba(242,240,235,0.38)` |
| `border` | `#1A1A1A` | `rgba(242,240,235,0.18)` |
| `borderSoft` | `#DDDAD3` | `rgba(242,240,235,0.08)` |
| `accent` | `#6D28D9` | `#A78BFA` |
| `accentSoft` | `#EDE9FE` | `rgba(167,139,250,0.15)` |
| `chipBg` | `#1A1A1A` | `#F2F0EB` |
| `chipText` | `#F2F0EB` | `#0D0B0A` |
| `btnPrimary` | `#1A1A1A` | `#F2F0EB` |
| `btnPrimaryText` | `#F2F0EB` | `#0D0B0A` |
| `scoreHigh` | `#1A7A4A` | `#4ADE80` |
| `scoreHighBg` | `#DCFCE7` | `rgba(74,222,128,0.12)` |
| `scoreMid` | `#A16207` | `#FBBF24` |
| `scoreMidBg` | `#FEF9C3` | `rgba(251,191,36,0.12)` |

### Component Rules
- **Cards:** 1.5px solid border (`border` token), 10px radius, `surface` background, no box-shadow on light / subtle on dark
- **Buttons (primary):** 0px radius or 5–6px, uppercase, 700 weight, 1.5px letter-spacing
- **Chips:** 3–4px radius, uppercase 700, `chipBg`/`chipText`. Accent variant uses `accent` fill
- **Section labels:** 8px, 700, 2px letter-spacing, uppercase, `textSecondary`
- **Ghost numbers:** Decorative oversized Syne number (opacity 0.05–0.08) positioned top-right of cards
- **Dividers:** 1.5px solid `border` at 40% opacity within cards; 1.5px solid `border` for screen-level dividers
- **Bottom nav:** Flat strip, 1.5px top border, uppercase 8px labels. Active tab has 2px `accent` top border strip

---

## Screens

### 1. Auth — Landing / Login / Signup
- Logo: `rumie` in Syne 800, accent-colored last 2 chars
- Tagline: "Find your perfect roommate." in `textSecondary`
- Fields: labeled inputs (8px uppercase label above), 1.5px `borderSoft` border, `surface` bg
- Primary CTA: "Sign in →" full-width, `btnPrimary` fill
- Divider: "or" with hairlines
- Secondary: "Continue with Google" outline button
- Footer: "No account? Create one →" with accent link

### 2. Discover (vertical scroll feed)
- Top bar: "Discover" (Syne 18px 800) + "{n} near you" metadata right
- Scrollable list of profile cards
- **Profile card structure:**
  - Ghost number top-right (01, 02…)
  - First + last name in Syne 800, two lines, accent color on last name
  - 1.5px divider
  - Stat row: Age · Location · Budget (each: Syne 13px value + 8px uppercase key)
  - Trait chips (uppercase, solid fill)
  - Action row: "Pass" outline btn (flex 1) + "Connect →" primary btn (flex 2)
- **No photos on cards** — text/info only
- Bottom nav active: Discover

### 3. Matches
- Top bar: "Matches" + "{n} new" badge
- List rows: 40px square avatar (letter placeholder, `accentSoft` bg, `accent` letter) · Name (Syne 800) + sub (location · move-in date) · Budget right-aligned
- Unread dot: 6px `accent` circle
- Bottom nav active: Matches

### 4. Messages / Chat list
- Same layout as Matches but shows last message preview (truncated) + timestamp
- Chat thread view: standard bubble layout, `surface` bg bubbles for received, `btnPrimary` for sent

### 5. Listings (with Value Score)
- Top bar: "Listings" + "{n} available"
- **Listing card structure:**
  - Value score badge top-left: large Syne number + "Value score" label + deal tier text ("Great deal" / "Fair deal" / "Below avg")
    - Score ≥75: green (`scoreHigh`/`scoreHighBg`)
    - Score 50–74: amber (`scoreMid`/`scoreMidBg`)
    - Score <50: red (semantic red)
  - 3 mini bar charts below badge: "vs Median" · "$/sqft" · "Transit"
  - Price: Syne 20px 800 + "/mo" in `textSecondary`
  - Address: 10px `textSecondary`
  - Soft divider
  - Spec row: Bed · Bath · Move-in · Size
- Bottom nav active: Listings

#### Value Score Algorithm
Score = weighted sum of 3 factors (0–100):

| Factor | Weight | Data source |
|--------|--------|-------------|
| Price vs neighborhood median rent | 40% | Rentcast API (zip-level median) |
| Price per sqft vs area average | 35% | Rentcast API |
| Transit / walk score | 25% | Walk Score API |

Each factor normalized 0–100 before weighting. Score cached per listing, refreshed daily.

### 6. Full Profile View (read-only, opened from Discover card tap)
- Full screen modal / pushed route
- Large Syne name at top + age
- **Photos:** Horizontal scroll strip (this is the only place photos appear in the app)
- Stats grid: 2×2 (Budget · Move-in · Room type · Lifestyle)
- Traits section with chips
- Bio block
- "Connect" CTA at bottom

### 7. Profile Setup (4-step flow, shown on first launch or when profile incomplete)

| Step | Fields |
|------|--------|
| 1 — Who are you? | Name, Age, Location, Bio |
| 2 — Budget & Timing | Budget range slider (min/max), Move-in timeline (chips), Preferred neighborhoods |
| 3 — Lifestyle | Schedule (chips: Early bird / Flexible / Night owl), Tidiness (chips), Traits (multi-select chips) |
| 4 — Photos | Up to 6 photos via image_picker. At least 1 required to complete profile. |

- Progress bar: 4 dots at top, fill left-to-right
- "← Back" left, "X of 4" badge right in top bar
- "Next →" primary btn, "← Back" outline btn below

### 8. Profile (tab — own profile view)
- Same structure as Full Profile View but with "Edit" badge in top bar
- Edit opens Profile Setup pre-filled

### 9. Settings
- Mini profile card at top (avatar + name + sub + "Edit →" accent link)
- Sections: Appearance · Discovery · Notifications · Account
- Appearance: Dark mode toggle, Theme (system/light/dark)
- Discovery: Max distance, Verified only toggle, Budget filter
- Notifications: New matches, Messages, Listing alerts (all toggles)
- Account: "Sign out" and "Delete account" in red

---

## Theme Toggle

- User can switch light ↔ dark in Settings
- System default also available
- `ThemeProvider` (already exists) drives `AppColors.isDark`
- All color tokens read from `AppColors` which gates on `isDark`

---

## Value Score — Technical Notes

- New `ValueScoreService` computes and caches scores
- Rentcast API key in `.env` / secure storage
- Walk Score API key in `.env` / secure storage
- Score stored on `ListingOut` model (or computed locally if API unavailable — fallback: "Score unavailable")
- Refresh: cached 24h, re-fetched on pull-to-refresh

---

## What Does NOT Change

- Navigation structure (4 tabs: Discover, Matches, Listings, Profile)
- Auth flow logic (just reskinned)
- Data models and API layer
- Provider/state architecture

---

## Out of Scope

- Backend changes
- Push notifications implementation
- Map view for listings
- Payments / premium tier
