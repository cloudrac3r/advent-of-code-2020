set -g debug_prints false

# Optionally load a different input file from first program argument.
set input_file (string sub $argv[1] input.txt)[1]

# Do maths with multiple operands.
function math_all
    set -l base $argv[1]
    for operand in $argv[2..-1]
        math $base$operand
    end
end

# Reimplement coreutils seq for ~20%
# It's faster because I don't need to open another process.
function builtin_seq
    set -l ac (count $argv)
    if contains $ac 2 3
        set -l i $argv[1]
        set -l step 1
        test $ac -eq 3; and set step $argv[2]
        while test $i -le $argv[-1]
            echo $i
            set i (math "$i + $step")
        end
    else
        # Calling this function incorrectly is a terminating error.
        echo "builtin_seq accepts 2 or 3 parameters. argv: $argv"
        exit 1
    end
end

function simple_disk_cache
    set -l dir cache
    set -l file $argv[1]
    set -l statement $argv[2]
    mkdir -p $dir
    if test -f $dir/$file
        echo "sdc: using cached $file" >&2
        cat $dir/$file
    else
        echo "sdc: generating result for $file" >&2
        set result ($statement)
        string sub -- $result > $dir/$file
        string sub -- $result
    end
end

# Loop over values, taking multiple values out, and getting values multiple times.
# Example: Input: 2 a b c d
#          Loop: a b; b c; c d
function for_multi
    set -l times $argv[1]
    set -l values $argv[2..-1]

    for s in (builtin_seq 1 1 (math (count $values) - $times + 1))
        set -l e (math $s + $times - 1)
        string sub -- $values[$s..$e]
    end
end

# Do maths on a variable in-place.
# Example input: "x + 1", would increment the variable x.
function var_math -S
    set -l name $argv[1]
    set -l calculation $argv[2..-1]

    set $name (math $$name $calculation)
end

function vector_math
    set -l count $argv[1]
    set -l operation $argv[2]
    set -e argv[1 2]
    set -l in1 $argv[1..$count]
    set -e argv[1..$count]
    set -l in2 $argv[1..$count]

    for i in (builtin_seq 1 1 $count)
        math "$in1[$i] $operation $in2[$i]"
    end
end

function se
    $debug_prints; and echo $argv >&2
end

function vse -S
    if $debug_prints
        set -l first true
        for v in $argv
            if not $first
                se -n ", "
            end
            se -n "$v: $$v"
            set first false
        end
        se
    end
end
