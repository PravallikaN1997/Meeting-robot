---

## [2026-05-28] — Onboarding UI Redesign

### ✅ Completed
- Replaced old robot asset with new Lottie JSON (robot.json, Dancing 1 animation)
- Fixed robot rendering — removed scaleEffect hack, set clean 140×140 frame using scaleEffect(0.405) formula (targetSize/346)
- Added dark/light mode toggle (pill-shaped, top-right of window, persisted via @AppStorage)
- Wrapped onboarding content in a card (white in light, #1A1A1E in dark)
- Added video background (robot-bg.mp4) replacing FluidGradientBackground
- Renamed "Meeting Robot" → "Meetbot" throughout
- Updated button labels → "Continue with Apple Calendar" / "Continue with Google Calendar"
- Added tagline: "Your AI meeting assistant"
- Added reason text: "So I know when your meetings are and can prep you in time."
- Added "Not Interested" text link below buttons
- Fixed message bubble cycle — fade in/out every 12s with 2s gap between messages
- Dark mode: pink glow with sparkle dots around robot
- Dark mode colors softened: card #1A1A1E, buttons off-white, reduced contrast
- Tuned all spacing: bubble→robot, robot→title, title→subtitle, subtitle→buttons

### 🐛 Bugs Fixed
- Robot was rendering tiny due to scaleEffect(0.15) — fixed with proper formula
- Negative spacers fighting each other — resolved with padding(.bottom) approach
- Dark mode pure black/white too harsh — softened to #1A1A1E and #F0F0F5
- Message bubble not fading out — replaced Timer with DispatchQueue chain

### 📐 Final Spacing Values
- Bubble → Robot: VStack spacing -15
- Robot bottom padding: -20
- Robot → Meetbot title: 8pt
- Meetbot → tagline: 4pt  
- Tagline → reason text: 4pt
- Reason text → buttons: 32pt

### 🔑 Key Formula
- Lottie scaleEffect = targetSize / 346 (native Lottie canvas size)

---
