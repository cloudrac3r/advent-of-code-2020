#!/usr/bin/env fish

source ../lib.fish $argv; or exit
set -g debug_prints false

set target_index 30000000
set batch_size 5000 # we divide work into batches to make it go faster
set numbers (string split , < $input_file) # starting numbers, this list is never changed later

set start_index (math (count $numbers))

for i in (builtin_seq 1 1 $start_index)
    set -l v index_cache_$numbers[$i]
    set -g $v $i
end

set last_number $numbers[-1]

set start_time (date +%s.%N) # timing and ETA

# Big loop with a test condition
while test $start_index -lt $target_index
    # If the batch is larger than the work to be done, we update the batch size
    # to the work size. If this passes, we're on the final iteration.
    if test (math $target_index - $start_index) -lt $batch_size
        set batch_size (math $target_index - $start_index)
    end

    # Loop of batch size. Using seq and looping for the entire batch is faster
    # than `while test` every single iteration.
    # The actual important code is inside this for loop.
    # All other code is just setup.
    for index in (seq $start_index (math "$start_index + $batch_size - 1"))
        # We use variables named `index_cache_X` where X is a number to look up
        # the index of the last time that number was seen.
        set -l v index_cache_$last_number

        if test $$v
            # The lookup succeeded. We get the difference between the current
            # index and the last index from the cache, which is the "age",
            # which is the current number.
            set last_number (math "$index - $$v")
        else
            # The lookup failed, so the current number is 0 as required.
            set last_number 0
        end

        # We're done with the current number, so cache its index.
        set -g $v $index
    end

    # This is the end of the batch. We set up the start of the next batch,
    # then report computation progress.
    var_math start_index + $batch_size
    set -l current_time (date +%s.%N)
    printf "%.2f%% complete, %.0fs taken, %.1fkn/s, eta %.1f min          \r" \
        (math "100 * $start_index / $target_index") \
        (math "$current_time - $start_time") \
        (math "$start_index / ($current_time - $start_time) / 1000") \
        (math "($target_index - $start_index) / ($start_index / ($current_time - $start_time)) / 60")
end

echo
echo answer: $last_number
