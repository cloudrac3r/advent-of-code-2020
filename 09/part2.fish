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

function find_invalid
    while read -l value
        if preamble_ended
            if not valid $value
                echo $value
                return
            end
            set -e buffer[1]
        end
        set -a buffer $value
    end < $input_file

    echo "All numbers are valid (a bad thing)"
    exit 1
end

set invalid (simple_disk_cache invalid find_invalid)

set s 1 # range start
set e 1 # range end
set list (cat $input_file)

while test $e -lt (count $list)
    set -l result (math $list[$s..$e]+ 0)
    if test $result -lt $invalid
        set e (math "$e + 1")
    else if test $result -gt $invalid
        set s (math "$s + 1")
    else
        set range (string sub $list[$s..$e] | sort -n)
        echo $range
        echo "answer:" (math $range[1 (count $range)]+ 0)
        exit
    end
end < $input_file
