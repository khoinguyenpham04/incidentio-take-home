# On-Call Schedule Renderer

A robust on-call scheduling system that generates rotating shift schedules and applies temporary overrides.

## Installation Instructions

To run this project, you will require a working Python 3 installation (Python 3.7 or higher recommended).

### Setup Instructions

#### 1. Verify Python Installation

Ensure Python 3 is installed on your system:

```bash
python3 --version
```

If Python is not installed, download it from [python.org](https://www.python.org/downloads/).

#### 2. Set Up Virtual Environment (Optional)

While not required, it's recommended to use a virtual environment to isolate project dependencies:

**On Unix/macOS/Linux:**

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate
```

**On Windows (PowerShell):**

```powershell
# Create virtual environment
python -m venv .venv

# Activate virtual environment
.\.venv\Scripts\Activate.ps1
```

**On Windows (Command Prompt):**

```cmd
# Create virtual environment
python -m venv .venv

# Activate virtual environment
.venv\Scripts\activate.bat
```

#### 3. Install Dependencies

There are **no external dependencies** required beyond Python's standard library.

#### 4. Make Script Executable (Unix/macOS/Linux Only)

On Unix-based systems, make the script executable:

```bash
chmod +x ./render-schedule
```

This allows you to run the script directly without explicitly invoking Python.

## Usage

### Running the Script

**On Unix/macOS/Linux:**

```bash
./render-schedule \
    --schedule=<path-to-schedule.json> \
    --overrides=<path-to-overrides.json> \
    --from='<ISO-8601-datetime>' \
    --until='<ISO-8601-datetime>'
```

**On Windows (PowerShell):**

```powershell
python render-schedule `
    --schedule=<path-to-schedule.json> `
    --overrides=<path-to-overrides.json> `
    --from='<ISO-8601-datetime>' `
    --until='<ISO-8601-datetime>'
```

**On Windows (Command Prompt):**

```cmd
python render-schedule ^
    --schedule=<path-to-schedule.json> ^
    --overrides=<path-to-overrides.json> ^
    --from=<ISO-8601-datetime> ^
    --until=<ISO-8601-datetime>
```

### Example

**On Unix/macOS/Linux:**

```bash
./render-schedule \
    --schedule=schedule.json \
    --overrides=overrides.json \
    --from='2025-11-07T17:00:00Z' \
    --until='2025-11-21T17:00:00Z'
```

**On Windows (PowerShell):**

```powershell
python render-schedule `
    --schedule=schedule.json `
    --overrides=overrides.json `
    --from='2025-11-07T17:00:00Z' `
    --until='2025-11-21T17:00:00Z'
```

**On Windows (Command Prompt):**

```cmd
python render-schedule ^
    --schedule=schedule.json ^
    --overrides=overrides.json ^
    --from=2025-11-07T17:00:00Z ^
    --until=2025-11-21T17:00:00Z
```

## Input File Formats

### Schedule Configuration (`schedule.json`)

Defines the rotating on-call schedule:

```json
{
  "users": ["alice", "bob", "charlie"],
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

The script outputs a JSON array of schedule entries to stdout:

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

## Algorithm Overview

### 1. Base Schedule Generation
Calculates the rotating schedule using modulo arithmetic to determine which user is on-call for each time period.

### 2. Override Application (Interval Splitting)
When an override overlaps with a base shift, the algorithm splits the shift into pieces:
- Part before override (if any) stays with original person
- Override period goes to covering person
- Part after override (if any) returns to original person

**Example:**
```
Base:     [Alice: 5pm Nov 7 → 5pm Nov 14]
Override: [Charlie: 5pm Nov 10 → 10pm Nov 10]

Result:
  [Alice: 5pm Nov 7 → 5pm Nov 10]
  [Charlie: 5pm Nov 10 → 10pm Nov 10]
  [Alice: 10pm Nov 10 → 5pm Nov 14]
```

### 3. Truncation
Entries are clipped to fit within the `--from` and `--until` bounds.

### 4. Optimization
Consecutive entries with the same user are merged for cleaner output.

## Testing

You can test the script with the provided example files to verify it's working correctly:

**On Unix/macOS/Linux:**

```bash
./render-schedule \
  --schedule=schedule.json \
  --overrides=overrides.json \
  --from='2025-11-07T17:00:00Z' \
  --until='2025-11-21T17:00:00Z'
```

**On Windows:**

```powershell
python render-schedule `
  --schedule=schedule.json `
  --overrides=overrides.json `
  --from='2025-11-07T17:00:00Z' `
  --until='2025-11-21T17:00:00Z'
```


## Edge Cases Handled

### Time Range Edge Cases
- ✅ Query range before/after schedule starts
- ✅ Very short query ranges (hours or minutes)
- ✅ Truncation at entry boundaries

### Override Edge Cases
- ✅ Override completely covers a base shift
- ✅ Override partially overlaps shift (start, middle, or end)
- ✅ Multiple overrides in sequence
- ✅ Overlapping overrides (later override takes precedence)
- ✅ Empty overrides array

### Schedule Configuration Edge Cases
- ✅ Single user in rotation
- ✅ Very short handover intervals
- ✅ Very long handover intervals
- ✅ Large number of users

### Error Handling
- ✅ Missing input files with clear error messages
- ✅ Invalid JSON format
- ✅ Missing required fields
- ✅ Invalid datetime formats
- ✅ Empty users array
- ✅ Negative or zero handover intervals
- ✅ Invalid time ranges

## Code Structure

```
render-schedule (main script)
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

### Algorithm: Interval Splitting
- Handles all overlap scenarios correctly
- Maintains chronological order
- Easy to reason about and debug
- Scalable to large numbers of overrides

### Validation Strategy
- Fail fast with clear error messages
- Validate inputs before processing
- Graceful degradation for recoverable issues

## Performance

**Time Complexity:**
- Base schedule generation: O(n) where n = shifts in range
- Override application: O(m × e) where m = overrides, e = entries
- Total: O(n + m × e) - fast for practical use cases

**Safety Limits:**
- Maximum 10,000 generated schedule entries (prevents infinite loops)


## Author

Solution for incident.io take-home challenge by Tran Khoi Nguyen (Noah) Pham

- LinkedIn: [linkedin.com/in/phamtrankhoinguyen-noah](https://www.linkedin.com/in/phamtrankhoinguyen-noah/)
- Portfolio: [noahpham.me](https://noahpham.me)
