# On-Call Schedule Renderer - Solution

## Overview

This solution implements a robust on-call scheduling system that generates schedules based on rotating shifts and applies temporary overrides. The system handles complex edge cases including overlapping overrides, truncation at time boundaries, and various schedule configurations.

## Requirements

- **Python 3.7 or higher** (uses type hints and standard library only)
- No external dependencies required

## Installation

1. Ensure Python 3 is installed:
```bash
python3 --version
```

2. Make the script executable (already done):
```bash
chmod +x ./render-schedule
```

That's it! The script uses only Python's standard library.

## Usage

### Basic Command

```bash
./render-schedule \
    --schedule=<path-to-schedule.json> \
    --overrides=<path-to-overrides.json> \
    --from='<ISO-8601-datetime>' \
    --until='<ISO-8601-datetime>'
```

### Example

```bash
./render-schedule \
    --schedule=schedule.json \
    --overrides=overrides.json \
    --from='2025-11-07T17:00:00Z' \
    --until='2025-11-21T17:00:00Z'
```

## Input File Formats

### Schedule Configuration (`schedule.json`)

Defines the rotating on-call schedule:

```json
{
  "users": [
    "alice",
    "bob",
    "charlie"
  ],
  "handover_start_at": "2025-11-07T17:00:00Z",
  "handover_interval_days": 7
}
```

**Fields:**
- `users` (array): List of usernames in rotation order (must have at least 1 user)
- `handover_start_at` (string): ISO 8601 datetime when the first shift starts
- `handover_interval_days` (number): Duration of each shift in days (must be positive)

### Overrides Configuration (`overrides.json`)

Defines temporary shift replacements:

```json
[
  {
    "user": "charlie",
    "start_at": "2025-11-10T17:00:00Z",
    "end_at": "2025-11-10T22:00:00Z"
  }
]
```

**Fields:**
- `user` (string): Username of the person covering the override
- `start_at` (string): ISO 8601 datetime when the override starts
- `end_at` (string): ISO 8601 datetime when the override ends

**Note:** Can be an empty array `[]` if no overrides are needed.

## Output Format

The script outputs a JSON array of schedule entries:

```json
[
  {
    "user": "alice",
    "start_at": "2025-11-07T17:00:00Z",
    "end_at": "2025-11-10T17:00:00Z"
  },
  {
    "user": "charlie",
    "start_at": "2025-11-10T17:00:00Z",
    "end_at": "2025-11-10T22:00:00Z"
  }
]
```

**Characteristics:**
- Entries are sorted chronologically by `start_at`
- No gaps or overlaps between entries
- Entries are truncated to fit within the `--from` and `--until` range
- Times are in ISO 8601 format with 'Z' suffix (UTC)

## Algorithm Explanation

### 1. Base Schedule Generation

The algorithm calculates which rotation cycle we're in and generates shifts:

1. Calculate time elapsed since `handover_start_at`
2. Determine which user is on-call using modulo arithmetic
3. Generate shifts until the `--until` time is reached
4. Optimization: Start from one rotation before the query range to catch overlapping shifts

**Time Complexity:** O(n) where n is the number of shifts in the query range

### 2. Override Application (Interval Splitting)

The core algorithm handles overlapping intervals:

```python
For each override:
  For each existing entry:
    If they overlap:
      - Keep portion before override (if any)
      - Keep portion after override (if any)
      - Remove the original entry
  Add the override entry
Sort all entries by start time
```

**Example:**
```
Base:     [Alice: 5pm Nov 7 → 5pm Nov 14]
Override: [Charlie: 5pm Nov 10 → 10pm Nov 10]

Result:
  [Alice: 5pm Nov 7 → 5pm Nov 10]
  [Charlie: 5pm Nov 10 → 10pm Nov 10]
  [Alice: 10pm Nov 10 → 5pm Nov 14]
```

**Time Complexity:** O(m × e) where m is number of overrides and e is number of entries

### 3. Truncation

Entries are truncated to fit within the `--from` and `--until` bounds:

- Entry start is adjusted to `max(entry.start, from_time)`
- Entry end is adjusted to `min(entry.end, until_time)`
- Entries completely outside the range are removed
- Zero-duration entries are filtered out

### 4. Optimization: Adjacent Entry Merging

Consecutive entries with the same user are merged:

```
Before: [Alice: 5pm-10pm], [Alice: 10pm-5am]
After:  [Alice: 5pm-5am]
```

## Edge Cases Handled

### Time Range Edge Cases
- ✅ Query range before schedule starts
- ✅ Query range far in the future
- ✅ Very short query ranges (hours or minutes)
- ✅ Truncation at entry boundaries

### Override Edge Cases
- ✅ Override completely covers a base shift
- ✅ Override partially overlaps shift (start, middle, or end)
- ✅ Multiple overrides in sequence
- ✅ Overlapping overrides (later override takes precedence)
- ✅ Empty overrides array
- ✅ Override by the same user already on-call (handled gracefully)

### Schedule Configuration Edge Cases
- ✅ Single user in rotation
- ✅ Very short handover intervals (hours)
- ✅ Very long handover intervals (months)
- ✅ Large number of users

### Error Handling
- ✅ Missing input files
- ✅ Invalid JSON format
- ✅ Missing required fields
- ✅ Invalid datetime formats
- ✅ Empty users array
- ✅ Negative or zero handover intervals
- ✅ Invalid time ranges (from >= until)
- ✅ Invalid override time ranges (start >= end)

## Testing

### Running Tests

The repository includes comprehensive test cases in the `test_cases/` directory:

```bash
# Test 1: No overrides
./render-schedule \
  --schedule=schedule.json \
  --overrides=test_cases/test1_no_overrides.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-21T17:00:00Z'

# Test 2: Multiple overrides
./render-schedule \
  --schedule=schedule.json \
  --overrides=test_cases/test2_multiple_overrides.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-21T17:00:00Z'

# Test 3: Single user schedule
./render-schedule \
  --schedule=test_cases/test3_single_user_schedule.json \
  --overrides=overrides.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-21T17:00:00Z'

# Test 4: Short interval (1 day)
./render-schedule \
  --schedule=test_cases/test4_short_interval_schedule.json \
  --overrides=test_cases/test1_no_overrides.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-14T17:00:00Z'

# Test 5: Override covering full shift
./render-schedule \
  --schedule=schedule.json \
  --overrides=test_cases/test5_override_full_shift.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-21T17:00:00Z'

# Test 6: Overlapping overrides
./render-schedule \
  --schedule=schedule.json \
  --overrides=test_cases/test6_overlapping_overrides.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-21T17:00:00Z'
```

### Test Coverage

The test suite validates:
- ✅ Basic rotation without overrides
- ✅ Single override in middle of shift
- ✅ Multiple non-overlapping overrides
- ✅ Overlapping overrides
- ✅ Override covering entire shift
- ✅ Single user rotation
- ✅ Short handover intervals (1 day)
- ✅ Truncation at start and end boundaries
- ✅ Very short query ranges
- ✅ Long query ranges (months)
- ✅ Error handling (missing files, invalid JSON, invalid configurations)

## Code Structure

```
render-schedule
├── ScheduleEntry class          # Data structure for schedule entries
├── parse_arguments()            # CLI argument parser
├── load_json_file()             # JSON file loader with error handling
├── parse_datetime()             # ISO 8601 datetime parser
├── validate_schedule()          # Schedule configuration validator
├── validate_override()          # Override configuration validator
├── generate_base_schedule()     # Base rotation schedule generator
├── apply_overrides()            # Override application with interval splitting
├── truncate_entries()           # Time boundary truncation
├── merge_adjacent_entries()     # Adjacent entry optimization
└── main()                       # Main orchestration logic
```

## Design Decisions

### 1. **Language Choice: Python**
- Excellent datetime handling with built-in `datetime` module
- Clear, readable syntax ideal for complex logic
- No external dependencies needed
- Fast enough for scheduling use cases

### 2. **Algorithm: Interval Splitting**
- Handles all overlap scenarios correctly
- Maintains chronological order
- Easy to reason about and debug
- Scalable to large numbers of overrides

### 3. **Validation Strategy**
- Fail fast with clear error messages
- Validate inputs before processing
- Graceful degradation for invalid overrides (warning + skip)

### 4. **Optimization**
- Merge adjacent entries with same user
- Start base schedule generation from optimal point
- Single pass for truncation

### 5. **Error Handling**
- Comprehensive input validation
- Clear error messages with context
- Non-zero exit codes for errors
- Warnings for skippable issues

## Scalability Considerations

The solution is designed to scale well:

1. **Time Range**: Can handle any reasonable time range (days to years)
2. **Users**: Works with any number of users (1 to thousands)
3. **Overrides**: Efficiently processes up to thousands of overrides
4. **Handover Intervals**: Supports intervals from minutes to months

**Performance Characteristics:**
- Base schedule generation: O(n) where n = shifts in range
- Override application: O(m × e) where m = overrides, e = entries
- Truncation: O(e) where e = entries
- Total: O(n + m × e) - typically very fast for practical use cases

**Safety Limits:**
- Maximum 10,000 generated schedule entries (prevents infinite loops)
- Can be increased if needed for very long time ranges

## Future Enhancements

Potential features that could be built on top of this scheduler:

1. **Handoff Notifications**: Alert users before their shift starts
2. **Coverage Analytics**: Report on user workload distribution
3. **Conflict Detection**: Warn when overrides conflict with personal calendars
4. **Multi-Schedule Support**: Handle multiple teams/services
5. **Time Zone Support**: Display times in user's local timezone
6. **Recurring Overrides**: Support for regular override patterns (e.g., every weekend)
7. **Schedule Templates**: Predefined rotation patterns
8. **Audit Log**: Track all schedule changes and overrides
9. **API Integration**: REST API for programmatic schedule management
10. **Web UI**: Visual schedule editor and viewer

## Author

Solution for incident.io take-home challenge

## License

Proprietary - incident.io take-home challenge

