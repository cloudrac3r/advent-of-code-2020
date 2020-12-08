#!/usr/bin/env fish

source ../lib.fish; or exit

set acc 0
set pct 1
set reached_instructions

set program (cat $input_file)

while true
    contains $pct $reached_instructions; and break
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
        case \*
            echo "Unknown op $op: $value"
            exit 1
    end
end < $input_file

echo "acc: $acc"
