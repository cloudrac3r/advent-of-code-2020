#!/usr/bin/env fish

source ../lib.fish; or exit

# Constants
set my_bag shiny_gold

# Globals
set all_bags
set tested_bags
set tested_bags_results
set confirmed_bags

# Decompose a rule line into a list of bags.
# argv:
#   [1] the rule line
# output:
#   [1]   the target bag
#   [2..] the bags it contains
#       [3] the number of times the bag is contained
#       [4] the kind of bag
function parse_line
    set -l line $argv[1]
    set -l words (string split ' ' $line)

    # Current bag
    string join _ $words[1 2]

    # Bags it contains
    set -l next 5
    while true
        # Test if there are more bags
        set -l next_word $words[$next]
        test "$next_word" != '' -a "$next_word" != 'no'; or return

        # Output next bag, move on
        echo $words[$next] # number
        string join _ $words[(math_all $next+ 1 2)] | string replace , '' # type
        set next (math "$next + 4")
    end
end

# Count the number of bags, recursively, inside this bag.
# Does not include the tested bag itself.
# argv:
#   [1] the bag to test
# output:
#   [1] the number of bags
function bag_contains_count
    set -l test_bag $argv[1]

    set -l contents $$test_bag

    # Have we already tested this bag?
    if set -l result_index (contains -i $test_bag $tested_bags)
        # Output the result from last time.
        echo $tested_bags_results[$result_index]
        return
    end

    # We haven't tested this bag yet, so recurse down all the inner bags.
    set -l sum 0
    string sub $contents | while read -Ll inner_quantity inner_type
        # The inner bag's count, plus the inner bag itself (1), all multiplied by the number of times that bag is contained.
        set sum (math "$sum + ("(bag_contains_count $inner_type)" + 1) * $inner_quantity")
    end

    # Store the result.
    set -a tested_bags $test_bag
    set -a tested_bags_results $sum

    # Output the result.
    echo $sum
end

# Load all bag rules from file

while read -l line
    set -l bag_data (parse_line $line)
    set -a all_bags $bag_data[1]
    set $bag_data[1] $bag_data[2..-1]
end < $input_file

# Count the bags inside my bag

bag_contains_count $my_bag
