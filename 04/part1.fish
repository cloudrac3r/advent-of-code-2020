set valid
set fields

function record
    if test (count (string match -a -r -- '^(?:hgt|pid|eyr|byr|iyr|ecl|hcl)$' $fields)) -eq 7
        set -a valid x
    end
end

while read -l line
    # next passport
    if not test $line
        record
        set fields
        set -a passports x
        continue
    end

    # process passport
    for field_data in (string split -- ' ' $line)
        set field (string split -- : $field_data)
        set -a fields $field[1]
    end
end < input.txt

record

count $valid
