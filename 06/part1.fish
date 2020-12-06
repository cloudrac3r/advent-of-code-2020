#!/usr/bin/env fish

set groups (perl -00e 'while (<>) { print substr($_, 0, -2) . "\0"; }' input.txt | string split0)

set sum 0

for group in $groups
    set unique_answers (count (string replace \n '' $group | string split '' | sort -u))
    set sum (math "$sum + $unique_answers")
end

echo $sum
