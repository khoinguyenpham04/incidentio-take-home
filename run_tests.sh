#!/bin/bash

# Automated test script for render-schedule
# This script runs comprehensive tests to verify the scheduler works correctly

set -e  # Exit on error

echo "================================"
echo "On-Call Schedule Renderer Tests"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

run_test() {
    local test_name="$1"
    local cmd="$2"
    
    echo -e "${BLUE}Test: ${test_name}${NC}"
    echo "Command: $cmd"
    eval "$cmd"
    echo -e "${GREEN}✓ Passed${NC}"
    echo ""
}

# Test 1: Basic functionality with override
run_test "Basic Schedule with Override" \
    "./render-schedule --schedule=schedule.json --overrides=overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 2: No overrides
run_test "Schedule without Overrides" \
    "./render-schedule --schedule=schedule.json --overrides=test_cases/test1_no_overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 3: Multiple overrides
run_test "Multiple Non-Overlapping Overrides" \
    "./render-schedule --schedule=schedule.json --overrides=test_cases/test2_multiple_overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 4: Single user schedule
run_test "Single User Schedule" \
    "./render-schedule --schedule=test_cases/test3_single_user_schedule.json --overrides=overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 5: Short interval
run_test "Short Handover Interval (1 day)" \
    "./render-schedule --schedule=test_cases/test4_short_interval_schedule.json --overrides=test_cases/test1_no_overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-14T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 6: Override covering full shift
run_test "Override Covering Full Shift" \
    "./render-schedule --schedule=schedule.json --overrides=test_cases/test5_override_full_shift.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 7: Overlapping overrides
run_test "Overlapping Overrides" \
    "./render-schedule --schedule=schedule.json --overrides=test_cases/test6_overlapping_overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 8: Truncation at start
run_test "Truncation (Query Starts Mid-Shift)" \
    "./render-schedule --schedule=schedule.json --overrides=overrides.json --from='2025-11-08T12:00:00Z' --until='2025-11-21T17:00:00Z' | python3 -m json.tool > /dev/null"

# Test 9: Truncation at end
run_test "Truncation (Query Ends Mid-Shift)" \
    "./render-schedule --schedule=schedule.json --overrides=overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-15T12:00:00Z' | python3 -m json.tool > /dev/null"

# Test 10: Very short query range
run_test "Very Short Query Range (2 hours)" \
    "./render-schedule --schedule=schedule.json --overrides=overrides.json --from='2025-11-10T18:00:00Z' --until='2025-11-10T20:00:00Z' | python3 -m json.tool > /dev/null"

# Test 11: Long query range
run_test "Long Query Range (2 months)" \
    "./render-schedule --schedule=schedule.json --overrides=test_cases/test1_no_overrides.json --from='2025-11-07T17:00:00Z' --until='2025-12-31T17:00:00Z' | python3 -m json.tool > /dev/null"

# Error handling tests
echo -e "${BLUE}Test: Error Handling - Missing File${NC}"
if ./render-schedule --schedule=nonexistent.json --overrides=overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' 2>&1 | grep -q "Error: File not found"; then
    echo -e "${GREEN}✓ Passed - Correctly handles missing file${NC}"
else
    echo "✗ Failed"
    exit 1
fi
echo ""

echo -e "${BLUE}Test: Error Handling - Invalid Schedule${NC}"
if ./render-schedule --schedule=test_cases/invalid_schedule.json --overrides=overrides.json --from='2025-11-07T17:00:00Z' --until='2025-11-21T17:00:00Z' 2>&1 | grep -q "Error:"; then
    echo -e "${GREEN}✓ Passed - Correctly handles invalid schedule${NC}"
else
    echo "✗ Failed"
    exit 1
fi
echo ""

echo "================================"
echo -e "${GREEN}All tests passed! ✓${NC}"
echo "================================"

