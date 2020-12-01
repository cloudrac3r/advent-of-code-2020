set input (cat input.txt)
set lines (count $input)

for i in (seq 1 $lines)
    for j in (seq 1 $lines)
        if test (math $input[$i] + $input[$j]) = 2020
            math $input[$i] \* $input[$j]
            exit
        end
    end
end
