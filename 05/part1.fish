for i in (seq 6 -1 0)
    set -a fb_quants (math 2 \^ $i)
end
for i in (seq 2 -1 0)
    set -a lr_quants (math 2 \^ $i)
end

set largest 0

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

    test $seat_id -ge $largest; and set largest $seat_id
end < input.txt

echo $largest
