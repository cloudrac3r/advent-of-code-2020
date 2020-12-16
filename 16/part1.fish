#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set file_sections (perl -00e 'while (<>) { print substr($_, 0, -2) . "\0"; }' $input_file | string split0)

# Load separate rules
set rule_names
for line in (string sub $file_sections[1])
    set -l parts (string split ': ' $line)
    set rule_name (string replace -a ' ' '_' $parts[1])
    set -a rule_names $rule_name
    set -l v "rule_$rule_name"
    for word in (string split ' ' $parts[2])
        test $word = or; and continue
        set -g -a $v (seq (string split -- - $word))
    end
end

# Coalesce all valid values
set valid_any (
for rule_name in $rule_names
    set -l v "rule_$rule_name"
    string sub $$v
end | sort -n -u
)

# Find invalid numbers anywhere
set total 0
rm -f result1.txt
for line in (string sub $file_sections[3])[2..-1]
    set line_ok true
    for number in (string split , $line)
        if not contains $number $valid_any
            var_math total + $number
            set line_ok false
        end
    end
    $line_ok; and echo $line >> result1.txt
end

echo $total
