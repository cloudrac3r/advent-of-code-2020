set ok
while read -l line
    # [2] min [3] max [4] letter [5] password
    set -l parts (string match -r '^([0-9]+)-([0-9]+) ([a-z]+): (.*)$' $line)
    set -l c (count (string match -a -r $parts[4] $parts[5]))
    if test $parts[2] -le $c -a $parts[3] -ge $c
        set -a ok x
    end
end < input.txt
count $ok
