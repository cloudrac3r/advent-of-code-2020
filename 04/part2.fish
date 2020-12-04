set valid
set fields_valid
set fields_seen

set input_file (string sub -- $argv[1] input.txt)[1]

function check
    set -l name $argv[1]
    set -l value $argv[2]

    test $value; or exit # ensure value actually exists, or the conditions will break

    contains $name $fields_seen; and exit # prevent double-counting of the same field
    set -a fields_seen $name

    function inner_check -S
        switch $name
            case byr # birth year
                test $value -ge 1920 -a $value -le 2002
            case iyr # issue year
                test $value -ge 2010 -a $value -le 2020
            case eyr # expiry year
                test $value -ge 2020 -a $value -le 2030
            case hgt # height
                string match -q -r -- '^[0-9]+(?:cm|in)$' $value; or return
                set -l number (string match -r -- '^[0-9]+' $value)
                if string match -q -- '*cm' $value
                    test $number -ge 150 -a $number -le 193
                else
                    test $number -ge 59 -a $number -le 76
                end
            case hcl # hair color
                string match -q -r -- '^#[0-9a-f]{6}$' $value
            case ecl # eye color
                contains $value amb blu brn gry grn hzl oth
            case pid # passport id
                string match -q -r -- '^[0-9]{9}$' $value
            case \*
                false
        end
    end

    inner_check; and set -a fields_valid x
end


function record
    test (count $fields_valid) -eq 7; and set -a valid x
end

while read -l line
    # next passport
    if not test $line
        # check current passport and add to total
        record
        # reset variables
        set fields_valid
        set fields_seen
        continue
    end

    # process part of passport
    for field_data in (string split -- ' ' $line)
        set field (string split -- : $field_data)
        check $field
    end
end < $input_file

record

count $valid
