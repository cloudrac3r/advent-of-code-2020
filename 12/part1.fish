#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set pos 0 0
set dir 2
set vectors "0 1" "1 0" "0 -1" "-1 0"
set vector_actions N E S W

while read -l line
    set -l action (string sub -s 1 -l 1 $line)
    set -l value (string sub -s 2 $line)
    switch $action
        case $vector_actions
            set -l vector (string split -- ' ' $vectors[(contains -i $action $vector_actions)])
            set vector (vector_math 2 \* $vector $value $value)
            set pos (vector_math 2 + $vector $pos)
        case R
            var_math dir + (math "$value / 90")
            while test $dir -gt 4
                var_math dir - 4
            end
        case L
            var_math dir - (math "$value / 90")
            while test $dir -lt 1
                var_math dir + 4
            end
        case F
            set -l vector (string split -- ' ' $vectors[$dir])
            set vector (vector_math 2 \* $vector $value $value)
            set pos (vector_math 2 + $vector $pos)
        case \*
            echo "unknown action $action $value"
            exit 1
    end
end < $input_file

echo "ending pos: $pos"
echo "ending distance:" (math "abs("$pos")"+ 0)
