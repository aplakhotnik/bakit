# Booking operations — notes from Retail Ops (Priya)

_2026-07-29. How we actually need bookings to work in store._

Each Experience has a **fixed number of spots** — a running club might take 20, a
fitting session 6. We cannot go over. Today it's a paper list and it's chaos.

What I need:

- When someone books, the spot count goes down by one. When it hits zero, the
  Experience shows as **full**.
- A **waitlist** when full would be great — if someone cancels, the next person on
  the list gets the spot. Not essential for launch but please design for it.
- **Check-in on the day.** I need to see who booked and tick them off. This only
  works if a booking is tied to a real identity — a name typed at booking isn't
  enough, people mistype and duplicate. This is why I keep pushing for **login to
  book**.
- **No-shows** hurt — someone books, doesn't turn up, and a spot was wasted. If
  rewards are involved, no-shows shouldn't earn anything.

Cancellations: people should be able to cancel up to some cut-off before the
Experience. What cut-off? Not sure — maybe a few hours before? Someone decide.
