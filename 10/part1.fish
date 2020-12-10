#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set adapts (sort -n $input_file)

set jumps 1 1 1

for_multi 2 $adapts | while read -L -l this next
    set -l diff (math "$next - $this")
    var_math jumps[$diff] + 1
end

math $jumps[1 3]\* 1
