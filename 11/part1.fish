#!/usr/bin/env fish

# ============
# To try with a smaller grid of seats, pass `test/sample.txt`
# as a command line argument.
# ============

source ../lib.fish $argv; or exit

set seats # list of all seats
set seats_width # width of the rows (all rows have same width)
set seats_height 0 # number of rows in the grid

# Calculate the index of a seat from its x and y coordinates.
# Coordinates here are 1-indexed, like fish lists.
function get_seat_index
    set -l x $argv[1]
    set -l y $argv[2]

    math "(($y - 1) * $seats_width) + $x"
end

# Get the seat at specific coordinates.
function get_seat
    echo $seats[(get_seat_index $argv)]
end

# Precompute the indexes of which (up to) 8 seats are next to to the seat
# targeted by coordinates.
# (If the seat is next to the edge of the grid, there will be fewer than 8.)
function compute_adjacent
    set -l x $argv[1]
    set -l y $argv[2]

    # The x and y files that actually have seats in them, i.e. are not at the edge.
    set available_x $x
    set available_y $y

    test $x -gt 1; and set -a available_x (math "$x - 1")
    test $x -lt $seats_width; and set -a available_x (math "$x + 1")
    test $y -gt 1; and set -a available_y (math "$y - 1")
    test $y -lt $seats_height; and set -a available_y (math "$y + 1")

    # Cartesian product x and y to get an (up to) 3x3 of grid coordinates
    # where seats may be
    set -l index (get_seat_index $x $y)
    set -l v seat_$index
    string sub $available_x\ $available_y | while read -l tx ty
        # Exclude the seat itself, the cartesian product creates it but we
        # don't actually want to check it.
        if test "$tx $ty" != "$x $y"
            # Add the index of the adjacent seat to a global variable to look up later.
            set -g -a $v (get_seat_index $tx $ty)
        end
    end
end

# Load all the seats from the file, calculating the width and height as we go.
while read -l line
    set seats_width (string length $line)
    set -a seats (string split '' $line)
    var_math seats_height + 1
end < $input_file

# Precompute adjacent seats
echo "Computing adjacent seats..."
time for y in (builtin_seq 1 1 $seats_height)
    for x in (builtin_seq 1 1 $seats_width)
        compute_adjacent $x $y
    end
end
echo "Done computing, starting seat transforms."

# Main loop.
# We will keep transforming the seats from $seats to $next_seats, comparing them at the end.
# Seats are transformed according to these rules:
#   . is floor and never changes
#   L is an empty seat, which will be filled if there are no full seats next to it
#   # is a full seat, which will be emptied if there are 4 or more full seats
#     next to it
# All seats change simultaneously, like in Life.
set iteration 0
while true
    # Prefill the list for the resulting seats.
    # Removing this line of code makes the entire program take 30% longer
    # (timed with test/sample.txt)
    set next_seats $seats

    # We'll time how long it takes to get to the next seat state.
    # 95 iterations are needed.
    # My computer takes 6 to 4 seconds per iteration on the full data.
    time begin
        # We will check each seat on each row and each column
        for index in (builtin_seq 1 1 (count $seats))
            # Get the current seat
            set -l seat $seats[$index]
            # Shortcut if it's floor, because floor never changes
            test $seat = .; and continue
            # Calculate the number of adjacent seats
            # Yes, string match and count here appears to be faster than
            # counting within the function and returning the count.
            set -l v seat_$index
            set -l full_adj (count (string match \# (string sub $seats[$$v])))
            # Finally, transform the seat based on the data we collected.
            if test $seat = \# -a $full_adj -ge 4
                # Crammed seat becomes empty
                set next_seats[$index] L
            else if test $seat = L -a $full_adj -eq 0
                # Spacious seat fills
                set next_seats[$index] \#
            end
        end

        # Print stats so that you can see that it's actually doing stuff
        var_math iteration + 1
        echo "Seat iteration $iteration done. First row of the seats:"
        string join '' $next_seats[1..$seats_width]
    end

    # If the seats are stable then we're done.
    # The puzzle answer is the number of occupied seats at that point.
    if test (string join '' $seats) = (string join '' $next_seats)
        echo "Finally, the answer. Occupied seats:" (count (string match \# $seats))
        exit
    end

    set seats $next_seats
end
