for i in (seq 6 -1 0)
    set -a fb_quants (math 2 \^ $i)
end
for i in (seq 2 -1 0)
    set -a lr_quants (math 2 \^ $i)
end

set seen

while read -l line
    set -l letters (string split '' $line)
    set -l row 0
    set -l col 0

    for i in (seq 1 (count $fb_quants))
        test $letters[$i] = B; and set row (math $row + $fb_quants[$i])
    end
    for i in (seq 1 (count $lr_quants))
        set -l j (math "$i + 7")
        test $letters[$j] = R; and set col (math $col + $lr_quants[$i])
    end

    set -l seat_id (math "$row * 8 + $col")

    set -a seen $seat_id
end < input.txt

set seen (string sub $seen | sort -n)

set seat_before $seen[1]
for i in (seq 2 (count $seen))
    set seat_here $seen[$i]
    if test (math "$seat_here - $seat_before") -eq 2
        math $seat_here - 1
        exit 0
    end
    set seat_before $seat_here
end

echo "Didn't find the seat."
exit 1
