# Optionally load a different input file from first program argument
set input_file (string sub $argv[1] input.txt)[1]

# seq from start to start+end, instead of start to end.
function seq_offset
    set -l base $argv[1]
    set -l start $argv[2]
    set -l step $argv[3]
    set -l offset $argv[4]

    if not test $offset
        echo "Must supply 4 parameters to seq_offset. argv: $argv"
        exit 1
    end

    seq -- (math "$base + $start") "$step" (math "$base + $offset")
end
