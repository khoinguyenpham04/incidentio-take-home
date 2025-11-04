# New Complex Test Cases Summary

## Overview
Added **4 new advanced test cases** (Tests 7-10) that significantly increase complexity and real-world coverage.

## Quick Stats

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Test Cases | 11 | 15 | +36% |
| Max Team Size | 3 | 12 | +300% |
| Max Overrides | 6 | 12 | +100% |
| Max Query Duration | 84 days | 84 days | - |
| Nesting Depth Tested | 2 | 4 | +100% |

## New Tests Details

### Test 7: Large Team Rotation
- **Teams**: 12 people
- **Interval**: 2-day rotation
- **Duration**: Full month (30 days)
- **Complexity**: Medium
- **Tests**: Scalability, modulo arithmetic, long-range queries
- **Override Count**: 0

### Test 8: Cascading Overrides (Most Complex)
- **Teams**: 3 people
- **Overrides**: 5 nested overrides
- **Duration**: 2 days
- **Complexity**: HIGH ⭐⭐⭐
- **Tests**: Interval splitting, precedence, deep nesting
- **Nesting Depth**: 4 levels

### Test 9: Swiss Cheese Pattern
- **Teams**: 12 people
- **Overrides**: 12 scattered small overrides
- **Duration**: 2 weeks
- **Complexity**: Medium
- **Tests**: Distribution, many non-overlapping intervals
- **Pattern**: No nesting, pure scatter

### Test 10: Boundary Precision (Edge Cases)
- **Teams**: 5 people
- **Overrides**: 5 microsecond-precision overrides
- **Duration**: 2 days
- **Complexity**: HIGH ⭐⭐⭐
- **Tests**: Sub-second timing, exact boundaries, zero-duration handling
- **Features**: 1-second intervals, microsecond collisions

## What Gets Tested Now

✅ **Scale**: Up to 12 concurrent team members
✅ **Complexity**: 4-level deep nested overrides
✅ **Duration**: Month-long queries with high frequency
✅ **Precision**: Sub-second and microsecond-level timing
✅ **Patterns**: Cascading, scattered, and grid-based distributions
✅ **Edge Cases**: Exact boundaries, zero-duration, microsecond collisions

## Running Tests

```bash
# Run all tests (including new ones)
./run_tests.sh

# Run just the new advanced tests
./render-schedule --schedule=test_cases/test7_large_team_schedule.json \
    --overrides=test_cases/test1_no_overrides.json \
    --from='2025-11-01T09:00:00Z' \
    --until='2025-11-30T09:00:00Z'

./render-schedule --schedule=schedule.json \
    --overrides=test_cases/test8_cascading_overrides.json \
    --from='2025-11-10T00:00:00Z' \
    --until='2025-11-12T00:00:00Z'

./render-schedule --schedule=schedule.json \
    --overrides=test_cases/test9_swiss_cheese_pattern.json \
    --from='2025-11-07T17:00:00Z' \
    --until='2025-11-21T17:00:00Z'

./render-schedule --schedule=schedule.json \
    --overrides=test_cases/test10_boundary_collisions.json \
    --from='2025-11-07T17:00:00Z' \
    --until='2025-11-09T17:00:00Z'
```

## Complexity Matrix

```
           Override Count
           0    5    10   12
         +----+----+----+----+
Team  3  | 2  | 8  |    |    |
Size 12  | 7  |    | 9  |    |
     5   |    |    |    | 10 |
         +----+----+----+----+
         2d  2d  14d  2d
       Duration
```

Legend: Number = Test number

## Files Added
- `test7_large_team_schedule.json` - 12 users, 2-day intervals
- `test8_cascading_overrides.json` - 5 nested overlapping overrides
- `test9_swiss_cheese_pattern.json` - 12 scattered 2-hour overrides  
- `test10_boundary_collisions.json` - Microsecond precision edge cases
- `ADVANCED_TEST_CASES.md` - Detailed documentation

