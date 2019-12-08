import sequtils, strutils, algorithm, deques

# --- Memory and registers ---

type CPU = ref object
    HALTED:bool
    IP:int
    MEM:seq[int]
    INPUT:seq[int]
    OUTPUT:seq[int]

# --- Helper templates ---

template A():int = cpu.MEM[if cpu.MEM[cpu.IP] div 100 mod 10 == 1: cpu.IP+1 else: cpu.MEM[cpu.IP+1]]
template B():int = cpu.MEM[if cpu.MEM[cpu.IP] div 1000 mod 10 == 1: cpu.IP+2 else: cpu.MEM[cpu.IP+2]]
template C():int = cpu.MEM[if cpu.MEM[cpu.IP] div 10000 mod 10 == 1: cpu.IP+3 else: cpu.MEM[cpu.IP+3]]

# --- Execute opcode at current IP ---

proc execute(cpu:CPU) =
  
    let opcodeNumber = cpu.MEM[cpu.IP] mod 100
    
    case opcodeNumber:
        of 01:  C = A + B;          inc(cpu.IP, 4)          # ADD
        of 02:  C = A * B;          inc(cpu.IP, 4)          # MUL
        of 03:                                              # POP_INPUT
            if cpu.INPUT.len > 0:                           # .
                A = cpu.INPUT.pop;  inc(cpu.IP, 2)          # .
        of 04:  cpu.OUTPUT.add(A);  inc(cpu.IP, 2)          # PUSH_OUTPUT
        of 05:  cpu.IP = if (A != 0): B else: (cpu.IP+3)    # JE
        of 06:  cpu.IP = if (A == 0): B else: (cpu.IP+3)    # JNE
        of 07:  C = (A < B).int;    inc(cpu.IP, 4)          # LESS
        of 08:  C = (A == B).int;   inc(cpu.IP, 4)          # EQUALS
        of 99:  cpu.HALTED = true                           # QUIT
        else:   discard

# --- Execute a program ---

proc run(cpu:CPU) =
    cpu.IP = 0
    while not cpu.HALTED:
        cpu.execute()

# --- Read and parse data ---

var data = readLines("input_07.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

var bestThrust = 0
var phases = @[0, 1, 2, 3, 4]
while true:
    # Initialize cpus
    var cpus = phases.mapIt(CPU(MEM: data, INPUT: @[it]))
    cpus[0].INPUT.insert(0, 0)
    
    # Run each cpu and connect input to output
    for i, cpu in cpus:
        cpu.run()
        let nextCpu = cpus[(i + 1) mod 5]
        nextCpu.INPUT.insert(cpu.OUTPUT[^1])
    
    # Get best thrust from 4th cpu
    bestThrust = max(bestThrust & cpus[4].OUTPUT)

    # Try next permutation
    if not phases.nextPermutation(): break

echo "Part 1: ", bestThrust

# --- Part 2 ---

bestThrust = 0
phases = @[5, 6, 7, 8, 9]

while true:
    # Initialize cpus
    var cpus = phases.mapIt(CPU(MEM: data, INPUT: @[it]))
    cpus[^1].OUTPUT = @[0]
    
    # Execute one opcode per cpu until last cpu has halted
    while not cpus[4].HALTED:
        for i, cpu in cpus:
            cpu.execute()
            
            # Transfer to next cpu and calculate best thrust
            cpus[(i + 1) mod 5].INPUT &= cpu.OUTPUT
            bestThrust = max(bestThrust & cpu.OUTPUT)
            cpu.OUTPUT = @[]
    
    # Try next permutation
    if not phases.nextPermutation(): break

echo "Part 2: ", bestThrust