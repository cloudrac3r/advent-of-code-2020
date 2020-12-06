#!/usr/bin/env fish

set groups (perl -00e 'while (<>) { print substr($_, 0, -2) . "\0"; }' input.txt | string split0)

set sum 0

for group in $groups
    set group_size (count (string sub -- $group))
    set everyone_answers (count (string replace \n '' $group | string split '' | sort | uniq -c | string match -r "^ *$group_size "))
    set sum (math "$sum + $everyone_answers")
end

echo $sum
