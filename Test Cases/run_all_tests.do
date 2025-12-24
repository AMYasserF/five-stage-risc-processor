# ==============================================================================
# Master Test Runner - Runs All Test Cases Sequentially
# ==============================================================================
# This script runs all 5 test cases one after another and generates a report
# ==============================================================================

puts "========================================"
puts "Master Test Runner"
puts "Running All Test Cases Sequentially"
puts "========================================"

# Set working directory
set base_dir "D:/CMP/Architecture/project/Test Cases"
cd $base_dir

# Create results directory if it doesn't exist
file mkdir "results"

# Get current timestamp
set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set report_file "results/test_report_$timestamp.txt"

# Open report file
set report [open $report_file w]
puts $report "=========================================="
puts $report "5-Stage RISC Processor Test Report"
puts $report "=========================================="
puts $report "Date: [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
puts $report "=========================================="
puts $report ""

# Function to run a test and capture results
proc run_test {test_name do_file report_handle} {
    puts "\n=========================================="
    puts "Running: $test_name"
    puts "=========================================="
    
    puts $report_handle "Test: $test_name"
    puts $report_handle "Time: [clock format [clock seconds] -format "%H:%M:%S"]"
    
    # Run the test
    if {[catch {source $do_file} result]} {
        puts "ERROR: Test failed with error: $result"
        puts $report_handle "Status: FAILED"
        puts $report_handle "Error: $result"
        puts $report_handle ""
        return 0
    } else {
        puts "SUCCESS: Test completed"
        puts $report_handle "Status: COMPLETED"
        puts $report_handle ""
        
        # Save waveform
        set wave_file "results/${test_name}_${timestamp}.wlf"
        catch {wlf save $wave_file}
        
        # Quit simulation before next test
        catch {quit -sim}
        
        return 1
    }
}

# Test counter
set total_tests 5
set passed_tests 0

# Run each test
puts $report "\n=========================================="
puts $report "Test Execution"
puts $report "=========================================="
puts $report ""

# Test 1: OneOperand
if {[run_test "OneOperand" "OneOperand.do" $report]} {
    incr passed_tests
}

# Test 2: TwoOperand
if {[run_test "TwoOperand" "TwoOperand.do" $report]} {
    incr passed_tests
}

# Test 3: Memory
if {[run_test "Memory" "Memory.do" $report]} {
    incr passed_tests
}

# Test 4: Branch
if {[run_test "Branch" "Branch.do" $report]} {
    incr passed_tests
}

# Test 5: BranchPrediction
if {[run_test "BranchPrediction" "BranchPrediction.do" $report]} {
    incr passed_tests
}

# Generate summary
puts $report "=========================================="
puts $report "Test Summary"
puts $report "=========================================="
puts $report "Total Tests: $total_tests"
puts $report "Passed: $passed_tests"
puts $report "Failed: [expr {$total_tests - $passed_tests}]"
puts $report "Success Rate: [expr {($passed_tests * 100) / $total_tests}]%"
puts $report "=========================================="

# Close report
close $report

# Display summary
puts "\n=========================================="
puts "All Tests Complete!"
puts "=========================================="
puts "Total Tests: $total_tests"
puts "Passed: $passed_tests"
puts "Failed: [expr {$total_tests - $passed_tests}]"
puts "Success Rate: [expr {($passed_tests * 100) / $total_tests}]%"
puts "=========================================="
puts "\nReport saved to: $report_file"
puts "Waveforms saved to: results/"
puts "=========================================="
