#!/usr/bin/env fish

source ../lib.fish $argv; or exit

set adapts (sort -n $input_file)

set jumps

for i in (builtin_seq 1 1 (math (count $adapts) - 1))
    set -l this $adapts[$i]
    set -l next $adapts[(math "$i + 1")]
    set -l diff (math "$next - $this")
    set jumps[$diff] (math "$jumps[$diff] + 1")
end

math "($jumps[1] + 1) * ($jumps[3] + 1)"
