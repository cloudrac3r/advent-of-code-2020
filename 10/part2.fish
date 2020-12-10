#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set adapts (sort -n $input_file)
set runs

set last_diff 1
for i in (builtin_seq 1 1 (math (count $adapts) - 1))
    # Imagine this pattern of joltage: 1  4  5  6  7  10 11 12 (15)
    # The gaps look like this:           3  1  1  1  3  1  1  3
    set -l this $adapts[$i]
    set -l next $adapts[(math "$i + 1")]
    set -l diff (math "$next - $this")

    # The gaps of 3 are not negotiable. The maximum jump is 3, so the adapters
    # at both ends of that jump are needed.
    # Because of this, let's change the number _after_ each jump of 3 to _also_ be 3.
    #   3  1  1  1  3  1  1  3
    #   3  3  1  1  3  3  1  3
    # Each 3 represents an adapter that _cannot_ be removed. Each 1 represents
    # an adapter that probably can.
    set -a runs (contains 3 $diff $last_diff; and echo 3; or echo 1)
    set last_diff $diff
end

# From earlier: the 3s can be used to group the 1s:
#   (1 1)   (1)
# Each group of optional adapters than has several possibilies, depending
# on the size of the group.
set group_multipliers
for n in (string length (string match -r -a '1+' (string join '' $runs)))
    set -l x 1
    switch $n
        case 1
            # The group has one adapter in it. It can either be included, or not.
            # 2^1 = 2 possibilities for this group.
            set x 2
        case 2
            # The group has two adapters in it. We can include
            # either both, neither, or either one.
            # 2^2 = 4 possibilities for this group.
            set x 4
        case 3
            # The group has three adapters in it. We can include all three,
            # any one, or any two, but we CANNOT skip them all, since then
            # the gap would be too large.
            # 2^3 = 8, -1 = 7 possibilities for this group.
            set x 7
        case \*
            # And that's all the group sizes that were in my puzzle input.
            # There were no cases of groups of size 4 or larger.
            # But if there were, I would continue to add them by hand.
            echo "Don't know what to do with $n adapters"
            exit 1
    end
    set -a group_multipliers $x
end

# Once we have all the possibilites for every group, we multiply them to get the
# final answer, since the groups can independently have any of their options.
math $group_multipliers\* 1
