#!/bin/bash

# Comprehensive comparison script for two on-call schedule implementations
# Compares outputs of render-schedule vs render-schedule-friend.py

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "═══════════════════════════════════════════════════════════════"
echo "  Comparing Two On-Call Schedule Implementations"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Your Solution:      ./render-schedule"
echo "Friend's Solution:  ./render-schedule-friend.py"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a comparison test
run_comparison_test() {
    local test_name="$1"
    local schedule_file="$2"
    local overrides_file="$3"
    local from_time="$4"
    local until_time="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test #${TOTAL_TESTS}: ${test_name}${NC}"
    echo "Schedule: $schedule_file"
    echo "Overrides: $overrides_file"
    echo "From: $from_time"
    echo "Until: $until_time"
    echo ""
    
    # Run your solution
    YOUR_OUTPUT=$(./render-schedule \
        --schedule="$schedule_file" \
        --overrides="$overrides_file" \
        --from="$from_time" \
        --until="$until_time" 2>&1)
    YOUR_EXIT_CODE=$?
    
    # Run friend's solution
    FRIEND_OUTPUT=$(./render-schedule-friend.py \
        --schedule="$schedule_file" \
        --overrides="$overrides_file" \
        --from="$from_time" \
        --until="$until_time" 2>&1)
    FRIEND_EXIT_CODE=$?
    
    # Compare outputs
    if [ "$YOUR_EXIT_CODE" -ne 0 ] && [ "$FRIEND_EXIT_CODE" -ne 0 ]; then
        echo -e "${YELLOW}⚠ Both solutions errored (expected for error test cases)${NC}"
        echo "Your exit code: $YOUR_EXIT_CODE"
        echo "Friend's exit code: $FRIEND_EXIT_CODE"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo ""
        return
    fi
    
    if [ "$YOUR_EXIT_CODE" -ne 0 ]; then
        echo -e "${RED}✗ Your solution errored but friend's didn't${NC}"
        echo "Your output:"
        echo "$YOUR_OUTPUT"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
        return
    fi
    
    if [ "$FRIEND_EXIT_CODE" -ne 0 ]; then
        echo -e "${RED}✗ Friend's solution errored but yours didn't${NC}"
        echo "Friend's output:"
        echo "$FRIEND_OUTPUT"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
        return
    fi
    
    # Normalize JSON (remove whitespace differences) and compare
    YOUR_NORMALIZED=$(echo "$YOUR_OUTPUT" | python3 -m json.tool --sort-keys 2>/dev/null || echo "$YOUR_OUTPUT")
    FRIEND_NORMALIZED=$(echo "$FRIEND_OUTPUT" | python3 -m json.tool --sort-keys 2>/dev/null || echo "$FRIEND_OUTPUT")
    
    if [ "$YOUR_NORMALIZED" = "$FRIEND_NORMALIZED" ]; then
        echo -e "${GREEN}✓ IDENTICAL OUTPUT${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Show the output
        echo ""
        echo "Output (both solutions agree):"
        echo "$YOUR_OUTPUT" | head -20
        if [ $(echo "$YOUR_OUTPUT" | wc -l) -gt 20 ]; then
            echo "... (output truncated)"
        fi
    else
        echo -e "${RED}✗ OUTPUTS DIFFER${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "Your Output:"
        echo "════════════════════════════════════════════════════════"
        echo "$YOUR_OUTPUT"
        
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "Friend's Output:"
        echo "════════════════════════════════════════════════════════"
        echo "$FRIEND_OUTPUT"
        
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "Diff (yours vs friend's):"
        echo "════════════════════════════════════════════════════════"
        diff <(echo "$YOUR_NORMALIZED") <(echo "$FRIEND_NORMALIZED") || true
    fi
    
    echo ""
}

# Test 1: Basic example from README
run_comparison_test \
    "Basic Schedule with Override (README example)" \
    "schedule.json" \
    "overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 2: No overrides
run_comparison_test \
    "Schedule without Overrides" \
    "schedule.json" \
    "test_cases/test1_no_overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 3: Multiple overrides
run_comparison_test \
    "Multiple Non-Overlapping Overrides" \
    "schedule.json" \
    "test_cases/test2_multiple_overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 4: Single user schedule
run_comparison_test \
    "Single User Schedule" \
    "test_cases/test3_single_user_schedule.json" \
    "overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 5: Short interval (1 day)
run_comparison_test \
    "Short Handover Interval (1 day)" \
    "test_cases/test4_short_interval_schedule.json" \
    "test_cases/test1_no_overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-14T17:00:00Z"

# Test 6: Override covering full shift
run_comparison_test \
    "Override Covering Full Shift" \
    "schedule.json" \
    "test_cases/test5_override_full_shift.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 7: Overlapping overrides
run_comparison_test \
    "Overlapping Overrides" \
    "schedule.json" \
    "test_cases/test6_overlapping_overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 8: Truncation - query starts mid-shift
run_comparison_test \
    "Truncation (Query Starts Mid-Shift)" \
    "schedule.json" \
    "overrides.json" \
    "2025-11-08T12:00:00Z" \
    "2025-11-21T17:00:00Z"

# Test 9: Truncation - query ends mid-shift
run_comparison_test \
    "Truncation (Query Ends Mid-Shift)" \
    "schedule.json" \
    "overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-11-15T12:00:00Z"

# Test 10: Very short query range
run_comparison_test \
    "Very Short Query Range (2 hours)" \
    "schedule.json" \
    "overrides.json" \
    "2025-11-10T18:00:00Z" \
    "2025-11-10T20:00:00Z"

# Test 11: Long query range
run_comparison_test \
    "Long Query Range (2 months)" \
    "schedule.json" \
    "test_cases/test1_no_overrides.json" \
    "2025-11-07T17:00:00Z" \
    "2025-12-31T17:00:00Z"

# Test 12: Query before schedule starts
run_comparison_test \
    "Query Before Schedule Starts" \
    "schedule.json" \
    "test_cases/test1_no_overrides.json" \
    "2025-11-01T00:00:00Z" \
    "2025-11-14T17:00:00Z"

# Test 13: Query at exact handover time
run_comparison_test \
    "Query at Exact Handover Time" \
    "schedule.json" \
    "test_cases/test1_no_overrides.json" \
    "2025-11-14T17:00:00Z" \
    "2025-11-28T17:00:00Z"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    COMPARISON SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Total Tests:    $TOTAL_TESTS"
echo -e "${GREEN}Passed:         $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed:         $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}Failed:         $FAILED_TESTS${NC}"
fi
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✓ ALL TESTS PASSED - SOLUTIONS ARE EQUIVALENT!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ✗ SOLUTIONS DIFFER - CHECK FAILED TESTS ABOVE${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi

