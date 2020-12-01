set input (sort -n input.txt)
set lines (count $input)
set target 2020

for i in (seq 1 $lines)
    for j in (seq 1 $lines)
        for k in (seq 1 $lines)
            set result (math $input[$i] + $input[$j] + $input[$k])
            if test $result -eq 2020
                math $input[$i] \* $input[$j] \* $input[$k]
                exit
            else if test $result -gt 2020
                break
            end
        end
    end
end
