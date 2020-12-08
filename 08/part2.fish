#!/usr/bin/env fish

source ../lib.fish; or exit

set program (cat $input_file)

function check_program
    set acc 0
    set pct 1
    set reached_instructions
    while true
        if not test $program[$pct]
            echo -e "\nacc: $acc"
            exit
        end
        contains $pct $reached_instructions; and return 1
        set -a reached_instructions $pct
        echo $program[$pct] | read -l op value
        switch $op
            case nop
                set pct (math "$pct + 1")
            case acc
                set acc (math "$acc + $value")
                set pct (math "$pct + 1")
            case jmp
                set pct (math "$pct + $value")
        end
    end < $input_file
end

# Looping and changing all instructions is terrible but it gets the job done.

for i in (seq 1 (count $program))
    test (math "$i % 10") -eq 0; and echo -sen "\rchecked $i of " (count $program)
    set -l original $program[$i]
    # Alter instruction
    set program[$i] (string replace -f nop jmp $program[$i]; or string replace jmp nop $program[$i]); or continue
    # Test program
    check_program
    # Restore instruction
    set program[$i] $original
end
