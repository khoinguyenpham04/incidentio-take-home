# File Guide - Quick Reference

## 📄 Main Files (Required for Submission)

### `render-schedule` ⭐
**The main executable script**
- 496 lines of Python code
- Implements the on-call scheduling algorithm
- Run with: `./render-schedule --schedule=... --overrides=... --from=... --until=...`
- No dependencies required (Python 3.7+ standard library only)

### `schedule.json` ⭐
**Example schedule configuration**
- Defines rotating on-call schedule
- 3 users: alice, bob, charlie
- 7-day handover interval
- Starts Friday, Nov 7, 2025 at 5pm UTC

### `overrides.json` ⭐
**Example overrides configuration**
- Array of temporary shift replacements
- Example: Charlie covers 5pm-10pm on Monday, Nov 10

### `SUBMISSION_README.md` ⭐
**Primary documentation for submission**
- Quick start guide
- Installation instructions
- Usage examples
- How the algorithm works
- Future product features

## 📚 Additional Documentation

### `SOLUTION_README.md`
**Detailed technical documentation**
- Complete algorithm explanation
- Time complexity analysis
- Comprehensive edge case documentation
- Code structure details
- Testing strategy
- Design decisions

### `IMPLEMENTATION_NOTES.md`
**Video walkthrough talking points**
- Script outline for 5-minute video
- Explanation of approach
- Code walkthrough guide
- Product features discussion
- Demo commands
- Anticipated questions & answers

### `PROJECT_SUMMARY.md`
**Project completion summary**
- All deliverables checklist
- Test results
- Technical strengths
- Development timeline
- File structure overview

### `FILE_GUIDE.md`
**This file**
- Quick reference for all files
- What each file contains
- How to use them

## 🧪 Testing Files

### `run_tests.sh`
**Automated test suite**
- Runs 13 comprehensive tests
- Validates all functionality
- Tests edge cases
- Checks error handling
- Execute with: `./run_tests.sh`

### `test_cases/` directory
Contains 7 test configurations:

1. **`test1_no_overrides.json`**
   - Empty overrides array `[]`
   - Tests basic schedule generation

2. **`test2_multiple_overrides.json`**
   - Multiple non-overlapping overrides
   - Tests sequential override application

3. **`test3_single_user_schedule.json`**
   - Schedule with only one user
   - Tests edge case of no rotation

4. **`test4_short_interval_schedule.json`**
   - 1-day handover interval
   - Tests frequent rotations

5. **`test5_override_full_shift.json`**
   - Override covering entire 7-day shift
   - Tests complete shift replacement

6. **`test6_overlapping_overrides.json`**
   - Overrides that overlap each other
   - Tests override precedence

7. **`invalid_schedule.json`**
   - Empty users array
   - Tests error handling

## 🔧 Configuration Files

### `.gitignore`
- Python cache directories
- IDE files
- OS temporary files

## 📖 Original Files (Provided)

### `README.md`
- Original take-home challenge description
- Requirements and expectations
- Submission instructions

### `schedule.png` & `schedule2025.png`
- Visual examples of schedules
- Provided with the challenge

## 📦 For Submission Package

**Essential files to include in ZIP:**

```
incident-io-takehome/
├── render-schedule              ← Main executable
├── schedule.json                ← Example schedule
├── overrides.json               ← Example overrides
├── run_tests.sh                 ← Test suite
├── test_cases/                  ← Test data
├── SUBMISSION_README.md         ← Start here!
├── SOLUTION_README.md           ← Technical docs
└── IMPLEMENTATION_NOTES.md      ← Video guide
```

**Optional but helpful:**
- PROJECT_SUMMARY.md
- FILE_GUIDE.md (this file)
- .gitignore

**Can exclude:**
- schedule.png, schedule2025.png (provided files)
- README.md (original challenge, already have it)

## 🚀 Usage Examples

### Basic usage:
```bash
./render-schedule \
    --schedule=schedule.json \
    --overrides=overrides.json \
    --from='2025-11-07T17:00:00Z' \
    --until='2025-11-21T17:00:00Z'
```

### Run all tests:
```bash
./run_tests.sh
```

### Test specific scenario:
```bash
./render-schedule \
    --schedule=test_cases/test3_single_user_schedule.json \
    --overrides=test_cases/test1_no_overrides.json \
    --from='2025-11-07T17:00:00Z' \
    --until='2025-11-21T17:00:00Z'
```

## 📋 Checklist for Submission

- [x] Main script works (`render-schedule`)
- [x] Example files provided
- [x] All tests passing
- [x] README with clear instructions
- [x] Code is well-documented
- [x] No external dependencies
- [ ] Record 5-minute video walkthrough
- [ ] Create ZIP file
- [ ] Submit with video link

## 💡 Tips for Video Recording

1. **Start with schedule visualization**
   - Show the schedule.png/schedule2025.png
   - Explain the problem visually

2. **Demonstrate the script**
   - Run basic example
   - Show output
   - Explain what happened

3. **Show code structure**
   - Quick tour of main components
   - Focus on interval splitting algorithm
   - Show one edge case handling

4. **Discuss product features**
   - 3-4 most impactful features
   - Business value
   - How they build on this foundation

5. **Keep it conversational**
   - Use IMPLEMENTATION_NOTES.md as guide
   - Don't read verbatim
   - Be enthusiastic about the solution!

## ❓ Quick FAQ

**Q: Which README should I read first?**
A: Start with SUBMISSION_README.md for quick overview, then SOLUTION_README.md for details.

**Q: How do I run the tests?**
A: Simply execute `./run_tests.sh`

**Q: What if Python is not in my PATH?**
A: You can run: `python3 render-schedule --schedule=... --overrides=...`

**Q: Can I modify the test files?**
A: Yes! Feel free to create your own test scenarios.

**Q: Do I need to install anything?**
A: No! Only Python 3.7+ required (standard library only).

## 🎯 Key Highlights to Mention

1. **Robust algorithm**: Handles all edge cases correctly
2. **Clean code**: Well-documented, typed, maintainable
3. **Comprehensive testing**: 13 tests, all passing
4. **No dependencies**: Standard library only
5. **Production-ready**: Error handling, validation, optimization
6. **Scalable**: Efficient algorithms for real-world use
7. **Extensible**: Easy to add new features
8. **Well-documented**: Multiple levels of documentation

Good luck with your submission! 🚀

