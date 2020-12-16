#!/usr/bin/env fish

source ../lib.fish $argv; or exit
set debug_prints false

set file_sections (perl -00e 'while (<>) { print substr($_, 0, -2) . "\0"; }' $input_file | string split0)

# Load separate rules
set rule_names
for line in (string sub $file_sections[1])
    set -l parts (string split ': ' $line)
    set rule_name (string replace -a ' ' '_' $parts[1])
    set -a rule_names $rule_name
    for word in (string split ' ' $parts[2])
        test $word = or; and continue
        set -g -a rule_$rule_name (seq (string split -- - $word))
    end
end

set total_lines (wc -l result1.txt | string split ' ')[1]

# Find what goes where

echo "Checking..."

while read -l line
    set -l numbers (string split , $line)
    for col_no in (builtin_seq 1 1 (count $numbers))
        for rule_name in $rule_names
            set -l v "rule_$rule_name"
            if contains $numbers[$col_no] $$v
                set -g -a "col_$col_no" $rule_name
            end
        end
    end
end < result1.txt

for i in (builtin_seq 1 1 (count $rule_names))
    set -l v "col_$i"
    set -g $v (string sub (string sub $$v | sort | uniq -c | string replace -rf "^\s*$total_lines (.*)" '$1'))
end

# Solve logic

echo "Solving..."

set done
while test (count $done) -lt (count $rule_names)
    for i in (builtin_seq 1 1 (count $rule_names))
        contains $i $done; and continue
        set -l v "col_$i"
        if test (count $$v) -eq 1
            se "there is one item in column $i: $$v"
            # this field must be done since there's only one option.
            # remove this option from all other fields.
            set -l value $$v
            for j in (builtin_seq 1 1 (count $rule_names) | string match -v $i)
                se "  editing column $j"
                set -l v "col_$j"
                set -g $v (string match -v $value $$v)
                se "  to $$v"
            end
            set -a done $i
            break
        end
    end
end

set result
for i in (builtin_seq 1 1 (count $rule_names))
    set -l v "col_$i"
    string match -q 'departure*' $$v; and set -a result $i
end

set ticket (string split , (string sub $file_sections[2])[2])

echo result: (math $ticket[$result]\* 1)
