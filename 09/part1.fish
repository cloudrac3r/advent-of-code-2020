#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set preamble_size 25
set buffer

function preamble_ended
    test (count $buffer) -eq $preamble_size
end

function valid
    set -l t $argv[1] # number to check
    for i in (builtin_seq 1 1 (math "$preamble_size - 1"))
        for j in (builtin_seq (math "$i + 1") 1 $preamble_size)
            test (math "$buffer[$i] + $buffer[$j]") -eq $t; and return
        end
    end
    return 1
end

while read -l value
    if preamble_ended
        if not valid $value
            echo "$value is not valid"
            exit
        end
        set -e buffer[1]
    end
    set -a buffer $value
end < $input_file

echo "All numbers are valid (a bad thing)"
exit 1
