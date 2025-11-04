# Advanced Test Cases

This document describes the new complex test scenarios for the on-call scheduler.

## Test 7: Large Team with Short Intervals

**File**: `test7_large_team_schedule.json`

**Scenario**:
- 12 team members rotating on 2-day intervals
- Tests scheduler with large team size and high turnover
- Duration: November 1-30, 2025 (30 days = 15 complete rotations)

**What it tests**:
- ✅ Efficiency with large number of users
- ✅ Modulo arithmetic with many rotation cycles
- ✅ Proper cycling through all team members
- ✅ Performance with month-long query ranges

**Expected output**: 15 entries (one per 2-day rotation)

---

## Test 8: Cascading Overlapping Overrides

**File**: `test8_cascading_overrides.json`

**Scenario**:
- 5 overrides that progressively overlap and nest within each other
- Times:
  - Bob: Nov 10, 09:00-17:00
  - Charlie: Nov 10, 13:00-21:00 (overlaps Bob's afternoon)
  - Diana: Nov 10, 15:00 - Nov 11, 09:00 (overlaps both Bob & Charlie)
  - Eve: Nov 10, 17:30-19:30 (inside Diana's window)
  - Frank: Nov 11, 01:00-05:00 (inside Diana's window)

**What it tests**:
- ✅ Complex nested interval splitting
- ✅ Proper precedence when overrides overlap (later = higher priority)
- ✅ Maintains chronological integrity through multiple layers
- ✅ Correctness with hours-long shifts broken into many pieces

**Expected output**: Multiple fragments where later overrides replace portions of earlier ones

---

## Test 9: Swiss Cheese Pattern

**File**: `test9_swiss_cheese_pattern.json`

**Scenario**:
- 12 small 2-hour overrides scattered across different days and times
- Creates fragmented coverage pattern with many small windows
- Each person covers a different time window throughout November

**What it tests**:
- ✅ Handling many non-overlapping overrides efficiently
- ✅ Pattern recognition and scheduling with irregular intervals
- ✅ Large number of entries without nesting complexity
- ✅ Time range spanning multiple weeks with distributed changes

**Expected output**: 12 override entries plus base schedule fragments between them

---

## Test 10: Boundary Collisions and Microsecond Precision

**File**: `test10_boundary_collisions.json`

**Scenario**:
- 5 overrides with exact timing collisions:
  - Alice: 1 second override (Nov 7, 17:00:00-17:00:01)
  - Bob: Overlaps Alice's time (17:00:00-17:30:00)
  - Charlie: Exactly at Bob's end (17:30:00)
  - Diana: Exactly at rotation boundary (Nov 8, 17:00:00)
  - Eve: Sub-second precision collision (16:59:59-17:00:01)

**What it tests**:
- ✅ Edge cases with zero-duration or 1-second intervals
- ✅ Exact boundary matching (start_at == end_at cases)
- ✅ Sub-second timing precision
- ✅ Floating-point comparison edge cases
- ✅ Handling microsecond-level overlaps

**Expected output**: Correctly handles timing precision without data loss

---

## Test Coverage Matrix

| Test | Team Size | Override Count | Nesting Depth | Duration | Complexity |
|------|-----------|-----------------|---|----------|-----------|
| 7    | 12        | 0               | 0 | 30 days  | Medium    |
| 8    | 3         | 5               | 4 | 2 days   | High      |
| 9    | 12        | 12              | 0 | 14 days  | Medium    |
| 10   | 5         | 5               | 2 | 2 days   | High      |

---

## Running Advanced Tests

```bash
# Run all new advanced tests
./run_tests.sh

# Run specific test
./render-schedule --schedule=test_cases/test7_large_team_schedule.json \
    --overrides=test_cases/test1_no_overrides.json \
    --from='2025-11-01T09:00:00Z' \
    --until='2025-11-30T09:00:00Z'
```

---

## Edge Cases Covered

- **Overlap Complexity**: Nested, cascading, and interleaving overrides
- **Timing Precision**: Microsecond-level collisions and zero-duration intervals
- **Scale**: Large teams (12+ users) with frequent rotations
- **Distribution**: Scattered overrides with no pattern
- **Boundaries**: Exact shift boundaries and sub-second transitions

