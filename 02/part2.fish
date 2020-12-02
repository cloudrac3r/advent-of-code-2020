set ok
while read -l line
    # [2] first [3] second [4] letter [5] password
    set -l parts (string match -r '^([0-9]+)-([0-9]+) ([a-z]+): (.*)$' $line)
    set -l letters (string split '' $parts[5])
    if test (count (string match $parts[4] $letters[$parts[2 3]])) -eq 1
        set -a ok x
    end
end < input.txt
count $ok
