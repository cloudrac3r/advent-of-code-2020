#!/usr/bin/env fish

cd (dirname (status current-filename))

source ../lib.fish; or exit

set width $argv[1]
set height $argv[2]
set row $argv[3]

set seats (cat cache/last.txt)

set next_seats $seats

function get_seat_index
    set -l x $argv[1]
    set -l y $argv[2]

    math "(($y - 1) * $width) + $x"
end

function get_seat
    echo $seats[(get_seat_index $argv)]
end

function p_in_bounds
    set -l x $argv[1]
    set -l y $argv[2]

    test $x -ge 1 -a $y -ge 1 -a $x -le $width -a $y -le $height
end

function get_visible_count
    set angles '-1 -1' '0 -1' '1 -1' '-1 0' '1 0' '-1 1' '0 1' '1 1'
    set seat_count 0

    for angle in $angles
        set -l tx $argv[1]
        set -l ty $row
        # echo "angle: $angle" >&2
        echo $angle | read -l xs ys
        # echo "s: $xs $ys" >&2
        while true
            var_math tx + $xs
            var_math ty + $ys
            if p_in_bounds $tx $ty
                set -l seat (get_seat $tx $ty)
                switch $seat
                    case \#
                        var_math seat_count + 1
                        break
                    case L
                        break
                end
            else
                break
            end
        end
    end

    # echo "sq result: $tx $row can see $seat_count" >&2

    echo $seat_count
end

for x in (builtin_seq 1 1 $width)
    set -l seat (get_seat $x $row)
    test $seat = .; and continue
    # echo "x: $x" >&2
    set -l seat_count (get_visible_count $x)
    # echo "here: $seat_count" >&2
    if test $seat = \# -a $seat_count -ge 5
        set next_seats[(get_seat_index $x $row)] L
    else if test $seat = L -a $seat_count -eq 0
        set next_seats[(get_seat_index $x $row)] \#
    end
end

echo $next_seats[(math "($row - 1) * $width + 1")..(math "$row * $width")]
