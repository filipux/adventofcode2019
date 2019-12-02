import sequtils, strutils

var mem:seq[int]
var ip = 0

type Opcode = enum 
    ADD = 1
    MUL = 2
    END = 99

template NAME():int = mem[ip]
template A():int = mem[mem[ip+1]]
template B():int = mem[mem[ip+2]]
template C():int = mem[mem[ip+3]]

proc execute():bool =
    case Opcode(NAME):
        of ADD: C = A + B
        of MUL: C = A * B
        of END: return false
    ip.inc(4)
    return true

proc run(data:seq[int]; noun,verb:int) =
    mem = data
    mem[1] = noun
    mem[2] = verb
    ip = 0
    while execute(): discard

# --- Read and parse data ---

let data = readLines("input_02.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

run(data, 12, 2)
echo "Part 1: ", mem[0]

# --- Part 2 ---
for a in 0..99:
    for b in 0..99:
        run(data, a, b)
        if mem[0] == 19690720:
            echo "Part 2: ", a,b