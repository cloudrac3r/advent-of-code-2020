#!/usr/bin/env fish

source ../lib.fish $argv; or exit
set debug_prints false

function solve_line
    set -l line $argv[1]

    set -l chars (string split '' $line | string match -v ' ')
    set -l index 1
    set -l stack
    set -l buffer

    while test $index -le (count $chars)
        set -l char $chars[$index]
        switch $char
            case 0 1 2 3 4 5 6 7 8 9
                set buffer "$buffer$char"
            case + '\*'
                set -a stack $buffer
                set buffer
                set -a stack $char
            case \(
                set -l result (solve_line (string join '' $chars[(math "$index + 1")..-1]))
                set -a stack $result[1]
                set index (math $index + $result[2])
            case \)
                break
        end
        var_math index + 1
    end

    test $buffer; and set -a stack $buffer

    for pos in (builtin_seq 1 1 (count $stack))
        if test $stack[$pos] = +
            set -l j (math "$pos - 1")
            set stack[$j] "($stack[$j]"
            set -l j (math "$pos + 1")
            set stack[$j] "$stack[$j])"
        end
    end

    math $stack; or exit
    echo $index
end

set sum

while read -l line
    var_math sum + (solve_line $line)[1]
end < $input_file

echo "sum: $sum"
