# CAMINO Mobile App - Complete UI/UX Reconstruction Spec

This document is a deep product and interface specification for the CAMINO Flutter mobile app.  
Its purpose is to let any engineer, designer, or AI model rebuild the same experience with high visual and behavioral fidelity.

---

## 1) Product Intent and Information Architecture

CAMINO is a role-based school transport app with three distinct user experiences:

- **Student app**: boarding pass first, live route awareness, alerts, personal profile and streak/points.
- **Parent app**: child tracking, payment visibility, notifications, linked child profile management.
- **Staff app**: operational shift dashboard, QR scanning flow, passenger manifest, route stop progression.

Primary navigation is role-specific but structurally consistent:

- **Entry flow**: `Splash -> Role Selection -> Login -> Role Home`.
- **Role homes** each use a **5-tab bottom navigation bar** (Material `NavigationBar` style).
- **Common utility pages**: Settings, Help & Support, About, and notification detail views.

Routing is handled with `go_router`, with dedicated path namespaces:

- Student: `/student/*`
- Parent: `/parent/*`
- Staff: `/staff/*`
- Shared: `/settings`, `/help`, `/about`

---

## 2) Visual Language and Brand System

### Core Brand Personality

CAMINO uses a premium, modern transport aesthetic: clean spacing, rounded geometry, high contrast, and iOS-like polish.

- **Brand primary**: deep green `#0A3D2F`
- **Dark variant primary**: `#1B6A56`
- **Support semantic colors**:
  - success `#10B981`
  - warning `#F59E0B`
  - error `#FF3B30`
  - info `#007AFF`

### Theme Strategy

- Global app supports both light and dark themes.
- Dark surfaces target OLED-like feel:
  - background `#000000`
  - card surface `#1C1C1E`
  - elevated surface `#2C2C2E`
- Light surfaces use soft grouped background:
  - background `#F2F2F7`
  - cards `#FFFFFF`
- Border tones:
  - dark `#38383A`
  - light `#E5E5EA`

### Typography

- Font family: **Inter** (via `google_fonts`).
- Heavy usage of:
  - bold/black weights for headers and hero statements.
  - uppercase micro-labels with letter-spacing for metadata.
- Visual hierarchy emphasizes:
  - large role-oriented hero text in auth (`~40px, 900`),
  - compact explanatory text (`14-16px`),
  - tiny uppercase labels (`10-12px`) for status and metadata.

### Spacing and Radius Tokens

- Spacing scale: `4, 8, 16, 24, 32, 48`
- Radius scale: `8, 12, 16, 24`
- Default CTA height: `56`
- Common card corner radius: `16`

---

## 3) Shared Component Library (Recreate Exactly)

### `CaminoAppBar`
- Custom top container (not plain stock AppBar look).
- Includes optional:
  - leading widget (avatar/back)
  - uppercase subtitle
  - notification icon bubble (toggleable)
- Uses role/theme-aware background and subtle borders.

### `CaminoCard`
- Rounded card with optional tap behavior.
- Theme-aware borders.
- Light-mode subtle premium shadow.
- Optional highlighted state (2px primary border).

### `CaminoButton`
Supports four variants:
- `primary` (filled brand)
- `secondary` (elevated neutral)
- `outline`
- `text`

States:
- normal
- loading spinner (left of label)
- optional icon
- full-width by default

### `CaminoTextField`
- Floating label style above input, uppercase micro-label.
- Focus border thickens (1px -> 2px) and becomes primary color.
- Optional prefix icon, password visibility toggle, custom suffix.
- Strong rounded container aesthetic.

### `StatusBadge`
- Pill shape, multiple statuses: success, warning, error, info, normal.
- Fill mode and outline mode.
- Uppercase text with tight letter spacing.

### `CaminoBottomNavBar`
- Uses Material `NavigationBar` destinations from role-specific item sets.
- Persistent per-role 5-tab structure.

### `MockMapBackground`
- Placeholder map panel with light/dark grid and centered map icon + "INTERACTIVE MAP" label.
- Used in student/parent/staff tracking-like surfaces.

---

## 4) Role-by-Role UX Breakdown

## A. Authentication Experience

### Splash
- Fade-in logo animation over 1500ms.
- Auto-transition to role selection at ~2500ms.
- Centered logo + circular progress indicator.

### Role Selection
- Intro: "Welcome to CAMINO" and role question.
- Three large role cards:
  - Student
  - Parent
  - Transport Staff
- Each card: icon bubble, title, subtitle, chevron.
- Top-right language chip ("EN", globe icon, dropdown indicator).

### Login
- Dynamic role copy:
  - Student Portal
  - Parent Access
  - Staff Operations
- Hero statement:
  - default "Welcome Back."
  - staff: "Ready for shift?"
- Fields: email + password.
- Actions:
  - Forgot password
  - Sign In (shows loading state before route)
  - Switch Role

### Forgot Password
- Enter email -> send instructions flow.
- Loading then success state with large green check icon.
- CTA switches to "Return to Login".

---

## B. Student App UX

Bottom tabs: `Home`, `QR Pass`, `Track`, `Alerts`, `Profile`

### Home (Boarding Pass Dashboard)
- Signature ticket-style layout with custom clipped card:
  - Top green route band with origin/destination airport-like codes.
  - Mid section with passenger identity and embedded QR.
  - Dashed separator.
  - Bottom "VALID FOR BOARDING" strip.
- Below pass: live vertical route timeline with completed/active/upcoming nodes.

### QR Pass
- Center-focused QR surface:
  - white rounded panel, glow shadow.
  - "SCAN TO BOARD" heading.
  - large QR code + student ID in monospace.
- Status badge and arrival message below.

### Track
- Full-screen map placeholder with overlaid bus icon.
- Bottom floating card:
  - bus id
  - "En Route" chip
  - current stop
  - ETA / distance / speed KPIs

### Alerts/Notifications
- List of category-styled notification tiles.
- Categories map to icon/color:
  - bus, payment, schedule, fallback general.
- Unread tiles get tinted background and stronger border.
- Tap opens detail view.

### Profile
- Avatar, student id, name.
- Gamification cards: points + streak.
- Info list: school, grade, language.
- Utility links: settings, help, about.
- Dark mode switch (Riverpod theme provider).
- Logout action.

---

## C. Parent App UX

Bottom tabs: `Home`, `Track`, `Payments`, `Alerts`, `Profile`

### Home (Parent Dashboard)
- Hybrid map + sculpted bottom-sheet composition:
  - top visual map area with floating bus chip.
  - gradient overlay greeting ("Good Morning, Sarah").
  - bottom curved panel with drag handle.
- Inside panel:
  - child tracking card (status ON BOARD, ETA, speed context)
  - account/payment card showing due amount and "Pay Now with MoMo" CTA.

### Track
- Full map + bus marker chip.
- Bottom child status card with:
  - identity
  - route context
  - ETA / distance / speed triplet.

### Payments
- Prominent balance card (currently `RWF 0`, "UP TO DATE").
- Primary CTA for paying term fees.
- Payment history list with term/date/amount.

### Alerts
- Same notification system as student, routed to parent detail path.

### Profile
- Parent identity panel.
- Linked child entry leading to linked-children screen.
- Settings list + dark mode toggle + support/about.
- Logout.

### Linked Children
- Card list of all linked students from mock data.
- Selecting a child returns back (placeholder behavior).

---

## D. Staff App UX

Bottom tabs: `Home`, `Scan`, `Passengers`, `Route`, `Profile`

### Home (Operational Dashboard)
- Top app bar indicates shift and route.
- Dominant circular capacity indicator:
  - `32 / 45` boarded
  - status badge "BOARDING ACTIVE"
  - current location context
- Large bottom tactile scan panel:
  - giant QR scanner icon
  - "TAP TO SCAN"
  - one-handed-use messaging

### Scan
- Camera placeholder background.
- Center scanner frame with accent border.
- Simulated scanning line.
- Bottom instruction card for proper QR alignment.

### Passengers
- Search bar + filter dropdown.
- Header summary (`32 / 45 Boarded`).
- Passenger rows with boarded/waiting visual states:
  - icon/avatar changes
  - status badges
  - muted text for waiting riders

### Route
- Full map underlay.
- Left-side translucent stop timeline panel.
- Stops show state:
  - completed
  - in progress
  - upcoming
- Marker and connector colors communicate progression.

### Profile
- Staff identity + assignment card (bus, route, shift).
- Settings/help/about shortcuts.
- Dark mode toggle.
- "End Shift & Logout" CTA.

---

## 5) Data Model and Mock Content Contracts

Current app uses local mock structures:

- `Student { id, name, school, grade, photoUrl, points, streakDays }`
- `Bus { id, routeName, capacity, currentPassengers, status, driverName }`
- `Trip { id, bus, date, time, fromStop, toStop, status }`
- `CaminoNotification { id, title, message, timeLabel, category, isUnread }`

Notable seeded values:
- Student id resembles `RW-STU-104`
- Bus is `Bus #12`, route `Route A`
- Notification categories: `bus`, `payment`, `schedule`

---

## 6) Interaction and Motion Rules

- Use smooth 150-250ms transitions for micro-interactions.
- Respect role-specific focused tasks:
  - student: "show pass fast"
  - parent: "status + payments quickly"
  - staff: "large touch targets for field operations"
- Keep button press feedback subtle (minimal splash).
- Preserve readable contrast in both themes.
- Maintain safe-area-aware vertical spacing.

---

## 7) Build-Recreation Prompt (Use This With Any Model)

Copy and provide the block below to an AI model to recreate the UI/UX with maximum fidelity:

```text
Rebuild a Flutter mobile app named CAMINO with a premium, role-based school transport UX.

Global requirements:
1) Use Flutter + Material 3 + go_router + Riverpod.
2) Implement light and dark themes with these tokens:
   - primary #0A3D2F, primaryDarkAlt #1B6A56
   - success #10B981, warning #F59E0B, error #FF3B30, info #007AFF
   - dark background #000000, dark surface #1C1C1E, dark elevated #2C2C2E
   - light background #F2F2F7, light surface #FFFFFF
   - dark border #38383A, light border #E5E5EA
3) Typography: Inter, bold-heavy hierarchy, uppercase metadata labels with letter spacing.
4) Shared components to implement: custom app bar, card, 4-variant button, elevated text field, status badge, bottom nav, map placeholder.
5) Entry flow: Splash (fade logo), Role Selection, role-based Login, Forgot Password.
6) Role homes with 5-tab bottom navigation:
   - Student: Home(boarding pass ticket UI + QR + timeline), QR Pass, Track(map+metrics), Alerts list + detail, Profile with points/streak + dark mode.
   - Parent: Home(map + curved bottom sheet + child status + payment due CTA), Track, Payments, Alerts + detail, Profile + linked children + dark mode.
   - Staff: Home(capacity ring + giant scan CTA), Scan(camera overlay frame), Passengers(search/filter/list states), Route(stop timeline on map), Profile + assignment + dark mode.
7) Add mock data models for student, bus, trip, and notifications.
8) Keep visual style: rounded cards, subtle shadows in light mode, high-contrast dark mode, tactile controls, operational clarity.
9) Prioritize exact UX behaviors: quick access to boarding/scanning, concise status chips, readable KPI triplets (ETA/distance/speed), role-focused navigation.

Deliver production-ready Flutter code structure with reusable widgets and clean routing.
```

---

## 8) Tech Stack Snapshot

- Flutter SDK `^3.10.4`
- `flutter_riverpod`
- `go_router`
- `google_fonts`
- `qr_flutter`
- `percent_indicator`
- (additional deps present: `fl_chart`, `intl`, `shimmer`, `flutter_svg`)

---

## 9) Notes for High-Fidelity Cloning

- Preserve uppercase labels and semantic chips; they are core to the CAMINO identity.
- Keep boarding-pass and operations dashboards visually dominant (hero-first design).
- Do not flatten into generic CRUD screens; this app relies on role-specific task framing.
- Ensure all three role apps feel related but functionally distinct.

