#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set pos 0 0
set wayp 10 1
set vectors "0 1" "1 0" "0 -1" "-1 0"
set vector_actions N E S W

while read -l line
    set -l action (string sub -s 1 -l 1 $line)
    set -l value (string sub -s 2 $line)
    switch $action
        case $vector_actions
            set -l vector (string split -- ' ' $vectors[(contains -i $action $vector_actions)])
            set vector (vector_math 2 \* $vector $value $value)
            set wayp (vector_math 2 + $vector $wayp)
        case R
            while test $value -ge 90
                set -l old_wayp $wayp
                set wayp[1] $old_wayp[2]
                set wayp[2] (math "-$old_wayp[1]")
                var_math value - 90
            end
        case L
            while test $value -ge 90
                set -l old_wayp $wayp
                set wayp[1] (math "-$old_wayp[2]")
                set wayp[2] $old_wayp[1]
                var_math value - 90
            end
        case F
            set -l vector (vector_math 2 \* $wayp $value $value)
            set pos (vector_math 2 + $vector $pos)
        case \*
            echo "unknown action $action $value"
            exit 1
    end
end < $input_file

echo "ending pos: $pos"
echo "ending distance:" (math "abs("$pos")"+ 0)
