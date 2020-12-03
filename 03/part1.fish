set x 0
set l
set trees

function exists
    count $argv >/dev/null
end

while read -l line
    # grab first line
    if not exists $l
        set l (string length $line)
        continue
    end

    # move toboggan
    set x (math "($x + 3) % $l")
    if test (string sub -s (math "$x + 1") -l 1 $line) = \#
        set -a trees x
    end
end < input.txt

count $trees
