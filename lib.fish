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
