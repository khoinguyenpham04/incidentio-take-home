# 3-Minute Walkthrough Script

## Introduction (0:00 - 0:30)

Hi! I'm going to walk you through my solution for the on-call scheduler challenge. The problem is straightforward: we need to rotate people through on-call shifts, but sometimes people swap shifts. My job was to build a script that figures out who's on-call when, handling all those swaps correctly.

The tricky part? When someone covers a shift in the middle of someone else's shift, we need to split it up properly. Like if Alice is supposed to be on-call all week, but Charlie covers Monday night, we need to show Alice before Monday, Charlie on Monday, then Alice again after Monday.

---

## Algorithm Choice (0:30 - 1:15)

I chose what I call an **interval splitting algorithm**. Here's why:

When I thought about the problem, I considered a few approaches. I could iterate through every minute or hour—but that's way too slow. I could use a complex sweep line algorithm—but that's overkill for this.

Instead, I went with interval splitting. The idea is simple: when an override overlaps with a base shift, I literally cut the shift into pieces. The part before the override stays with the original person, the override period goes to the new person, and the part after goes back to the original person.

Let me show you an example. Say Alice is on-call from Friday 5pm to the next Friday 5pm. But Charlie covers Monday 5pm to 10pm. The algorithm splits Alice's shift into three pieces: Alice Friday to Monday, Charlie Monday evening, then Alice again Monday night through Friday.

This approach is clean, easy to reason about, and handles all the edge cases—like when overrides completely cover a shift, or when multiple overrides overlap.

---

## Code Walkthrough (1:15 - 2:30)

The code follows a simple pipeline. Let me show you the main pieces:

First, `generate_base_schedule` creates the rotating schedule. It figures out which rotation cycle we're in using some simple math—basically calculating how many intervals have passed since the start date, then using modulo to cycle through the users.

Next, `apply_overrides` is where the magic happens. For each override, it finds all the base entries that overlap, splits them up, and inserts the override. The key function here is `intervals_overlap`—it checks if two time ranges overlap using a simple comparison: does one start before the other ends?

Then `truncate_entries` clips everything to the time range you asked for. If a shift starts before your "from" time, it gets cut off at the start. Same for the end.

Finally, `merge_adjacent_entries` is a nice optimization—if Alice has two shifts right next to each other, it combines them into one. Makes the output cleaner.

The whole thing is written in Python using only the standard library. No external dependencies means it's easy to run and deploy. I chose Python because datetime handling is built-in and excellent, and the code stays readable even with all the edge cases.

---

## Design Decisions (2:30 - 3:00)

A few key design choices:

First, I validate everything upfront. If your input is bad, you get a clear error message right away—no mysterious bugs later.

Second, I handle errors gracefully. Invalid overrides get skipped with a warning instead of crashing the whole program.

Third, the algorithm is designed to be correct first, then optimized. I added the merging step to keep output clean, but the core logic prioritizes correctness over speed.

The code structure is simple and modular. Each function does one thing well, which makes it easy to test and debug. I've tested it with edge cases like overlapping overrides, single-user schedules, and very short time intervals—everything works correctly.

That's it! The solution handles all the requirements and edge cases, and it's ready to build product features on top of—like notifications, analytics, or calendar integrations.

