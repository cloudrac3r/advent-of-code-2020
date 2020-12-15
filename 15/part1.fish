#!/usr/bin/env fish

source ../lib.fish; or exit

set numbers (string split , < input.txt)
set target_index 2020
set index (count $numbers)

while test $index -lt $target_index
    if set found_index (contains -i -- $numbers[-1] $numbers[-2..1])
        set -a numbers $found_index
    else
        set -a numbers 0
    end
    var_math index + 1
end

echo $numbers[-1]
