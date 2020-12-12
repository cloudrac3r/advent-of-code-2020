#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set seats
set seats_width
set seats_height 0
set next_seats

mkdir -p cache

while read -l line
    set seats_width (string length $line)
    set -a seats (string split '' $line)
    var_math seats_height + 1
end < $input_file

function get_seat_index
    set -l x $argv[1]
    set -l y $argv[2]

    math "(($y - 1) * $seats_width) + $x"
end

function get_seat
    echo $seats[(get_seat_index $argv)]
end

function print_seats
    for y in (builtin_seq 1 1 $seats_height)
        for x in (builtin_seq 1 1 $seats_width)
            printf '%s' (get_seat $x $y)
        end
        echo
    end
    echo
end

while true
    # print_seats
    string join '' $seats[1..$seats_width]

    set next_seats

    time begin
        string sub $seats > cache/last.txt
        set next_seats (parallel -k -j 7 "fish ~/Code/advent/2020/11/process_rows.fish $seats_width $seats_height {}" ::: (builtin_seq 1 1 $seats_height))
        # for s in (builtin_seq 1 1 $seats_height); set -a next_seats (fish process_rows.fish $seats_width $seats_height $s); end
        # print_seats
    end

    set next_seats (string split ' ' $next_seats)

    if test (string join '' $seats) = (string join '' $next_seats)
        echo "occupied seats:" (count (string match \# $seats))
        exit
    end

    set seats $next_seats
end
