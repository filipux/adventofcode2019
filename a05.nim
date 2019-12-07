import sequtils, strutils

# --- Memory and registers ---

# Why uppercase? Looks cool and helps separate from other variables!

var IP = 0
var MEM:seq[int]
var INPUT:seq[int]
var OUTPUT:seq[int]

# --- Helper templates ---

template A():int = MEM[if MEM[IP] div 100 mod 10 == 1: IP+1 else: MEM[IP+1]]
template B():int = MEM[if MEM[IP] div 1000 mod 10 == 1: IP+2 else: MEM[IP+2]]
template C():int = MEM[if MEM[IP] div 10000 mod 10 == 1: IP+3 else: MEM[IP+3]]

# --- Execute opcode at current IP ---

proc execute():bool =
    let opcodeNumber = MEM[IP] mod 100
    
    case opcodeNumber:
        of 01: C = A + B;           inc(IP, 4)      # ADD
        of 02: C = A * B;           inc(IP, 4)      # MUL
        of 03: A = INPUT.pop;       inc(IP, 2)      # POP_INPUT
        of 04: OUTPUT.add(A);       inc(IP, 2)      # PUSH_OUTPUT
        of 05: IP = if (A != 0): B else: (IP+3)     # JE
        of 06: IP = if (A == 0): B else: (IP+3)     # JNE
        of 07: C = (A < B).int;     inc(IP, 4)      # LESS
        of 08: C = (A == B).int;    inc(IP, 4)      # EQUALS
        of 99: return false                         # QUIT
        else: discard
    
    return true

# --- Execute a program ---

proc run(data:seq[int]) =
    MEM = data
    IP = 0
    while execute(): discard

# --- Read and parse data ---

var data = readLines("input_05.txt")[0].split(",").map(parseInt)

# --- Part 1 ---
INPUT.add(1)
run(data)
echo "Part 1: ", OUTPUT.pop

# --- Part 1 ---
INPUT.add(5)
run(data)
echo "Part 2: ", OUTPUT.pop
