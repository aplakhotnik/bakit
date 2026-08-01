# Onboarding & booking — design discovery notes

_Experience Designer, 2026-07-24. Personas and the onboarding journey as I see it.
Shared ahead of the next workshop._

## Personas (short)

- **Maya, 24** — new joiner, runs a few times a week. Wants to join fast and book a
  running-club **experience** on day one. Will abandon anything slow or spammy.
- **Deno, 38** — returning enthusiast. Wants early access to launches and to feel
  rewarded for showing up.
- **Priya (internal)** — Retail Ops, runs the in-store experiences. Needs to know
  who's coming and manage a fixed number of spots.

(I use **"experience"** for the bookable thing — "class"/"session"/"event" are all
floating around; we should standardise.)

## Onboarding journey (happy path)

1. Maya taps "Join" → enters email → verifies.
2. She's asked for **consent** to be contacted (this step depends entirely on the
   legal basis, which we don't have yet — I can't finalise this screen).
3. She picks or is defaulted to a tier.
4. She lands on a list of experiences and books one.

## Booking & identity

- To manage capacity and check people in on the day, **a booker needs an identity —
  I think booking should require being logged in.** "Guest booking with just a name
  and email" sounds friendly but Ops can't trust it and it breaks check-in.
  - (I know the workshop leaned the other way. I'd push back.)

## Accessibility

- This is a public consumer journey; it must meet a real accessibility bar. **What's
  our target — WCAG 2.1 AA?** I've assumed AA in the flows but no one has confirmed
  the level. Please decide, it affects component choices.

## Open, from my side

- Confirm the accessibility target (assumed AA).
- Confirm login-required vs guest booking.
- Consent copy — blocked on Legal.
