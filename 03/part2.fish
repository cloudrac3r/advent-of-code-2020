set list_x 1 3 5 7 1
set list_y 1 1 1 1 2
set trees_list

function exists
    count $argv >/dev/null
end

for i in (seq 1 (count $list_x))
    set -l x 0
    set -l skip 0
    set -l route_trees
    set -l l

    while read -l line
        # grab first line
        if not exists $l
            set l (string length $line)
            continue
        end

        # skip line?
        set skip (math "($skip + 1) % $list_y[$i]")
        if test $skip -ne 0
            continue
        end

        # move toboggan
        set x (math "($x + $list_x[$i]) % $l")
        if test (string sub -s (math "$x + 1") -l 1 $line) = \#
            set -a route_trees x
        end
    end < input.txt

    set -a trees_list (count $route_trees)
end

math (string join \* $trees_list)
