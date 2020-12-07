#!/usr/bin/env fish

set input_file (string sub $argv[1] input.txt)[1]

# Constants
set my_bag shiny_gold

# Globals
set all_bags
set tested_bags
set confirmed_bags

# Decompose a rule line into a list of bags.
# argv:
#   [1] the rule line
# output:
#   [1]   the target bag
#   [2..] the bags it contains
function parse_line
    set -l line $argv[1]
    set -l words (string split ' ' $line)

    # Current bag
    string join _ $words[1 2]

    # Bags it contains
    set -l next 6
    while true
        # Test if there are more bags
        set -l next_word $words[$next]
        test "$next_word" != '' -a "$next_word" != 'other'; or return

        # Output next bag, move on
        string join _ $words[$next] $words[(math "$next + 1")] | string replace , ''
        set next (math "$next + 4")
    end
end

# Test, recursively, if a bag contains my bag.
# If it does, add it to $confirmed_bags.
# Either way, add it to $tested_bags.
# argv:
#   [1] the bag to test
# return:
#   0: the tested bag can contain
#   1: the tested bag cannot contain
function bag_contains_my_bag
    set -l test_bag $argv[1]

    # Test for my bag, which is the recursion base case.
    if test $test_bag = $my_bag
        return 0
    end

    # Have we already tested this bag?
    if contains $test_bag $tested_bags
        # Return the result from last time.
        contains $test_bag $confirmed_bags
        return
    end

    # We haven't tested this bag yet, so recurse down all the inner bags.
    for inner_bag in $$test_bag
        if bag_contains_my_bag $inner_bag
            set -a tested_bags $test_bag
            set -a confirmed_bags $test_bag
            return 0
        end
    end

    # None of the inner bags contain my bag, so this bag doesn't either.
    set -a tested_bags $test_bag
    return 1
end

# Load all bag rules from file

while read -l line
    set -l bag_data (parse_line $line)
    set -a all_bags $bag_data[1]
    set $bag_data[1] $bag_data[2..-1]
end < $input_file

# Check all existing bags

for bag in $all_bags
    bag_contains_my_bag $bag
end

# And we have the answer!

count $confirmed_bags
