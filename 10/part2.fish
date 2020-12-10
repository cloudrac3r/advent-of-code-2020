#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set adapts (sort -n $input_file)
set runs

set diff_history 1
for_multi 2 $adapts | while read -L -l this next
    # Imagine this pattern of joltage: 1  4  5  6  7  10 11 12 (15)
    # The gaps look like this:           3  1  1  1  3  1  1  3
    set -l diff (math "$next - $this")
    set -p diff_history $diff

    # The gaps of 3 are not negotiable. The maximum jump is 3, so the adapters
    # at both ends of that jump are needed.
    # Because of this, let's change the number _after_ each jump of 3 to _also_ be 3.
    #   3  1  1  1  3  1  1  3
    #   3  3  1  1  3  3  1  3
    # Each 3 represents an adapter that _cannot_ be removed. Each 1 represents
    # an adapter that probably can.
    set -a runs (contains 3 $diff_history[1 2]; and echo 3; or echo 1)
end

# From earlier: the 3s can be used to group the 1s:
#   (1 1)   (1)
# Each group of optional adapters than has several possibilies, depending
# on the size of the group.
#   - The group has one adapter in it. It can either be included, or not.
#     2^1 = 2 possibilities for this group.
#   - The group has two adapters in it. We can include
#     either both, neither, or either one.
#     2^2 = 4 possibilities for this group.
#   - The group has three adapters in it. We can include all three,
#     any one, or any two, but we CANNOT skip them all, since then
#     the gap would be too large.
#     2^3 = 8, -1 = 7 possibilities for this group.
# And that's all the group sizes that were in my puzzle input.
# If there were larger groups, I would continue to add them by hand.
# Now we simply map our list of group sizes to a list of multipliers, then
# do the calculation.
set group_sizes (string length (string match -r -a '1+' (string join '' $runs)))
set group_multipliers 2 4 7
math $group_multipliers[$group_sizes]\* 1
