import sequtils, strutils

# --- Memory and registers ---

type CPU = ref object
    MEM:seq[int]
    INPUT:seq[int]
    IP:int
    BP:int
    HALTED:bool
    OUTPUT:seq[int]

# --- Helper templates ---
    
template getMemoryForParameter(param:int):int =
    let opcodeOffset = [0,100,1000,10000][param]
    let mode = cpu.MEM[cpu.IP] div opcodeOffset mod 10
    let address = case mode:
        of 0: cpu.MEM[cpu.IP + param]
        of 1: cpu.IP + param
        of 2: cpu.MEM[cpu.IP + param] + cpu.BP
        else: echo "invalid mode"; 0
    
    # Increase size of memory if needed
    cpu.MEM.setLen(1 + max(cpu.MEM.len, address))
    cpu.MEM[address]
        
template A():int = getMemoryForParameter(1)
template B():int = getMemoryForParameter(2)
template C():int = getMemoryForParameter(3)

# --- Execute opcode at current IP ---

proc execute(cpu:CPU) =
  
    let opcodeNumber = cpu.MEM[cpu.IP] mod 100
    
    case opcodeNumber:
        of 01:  C = A + B;           inc(cpu.IP, 4)          # ADD
        of 02:  C = A * B;           inc(cpu.IP, 4)          # MUL
        of 03:                                               # POP_INPUT
            if cpu.INPUT.len > 0:                            # .
                A = cpu.INPUT.pop;   inc(cpu.IP, 2)          # .
        of 04:  cpu.OUTPUT.add(A);   inc(cpu.IP, 2)          # PUSH_OUTPUT
        of 05:  cpu.IP = if (A != 0): B else: (cpu.IP+3)     # JE
        of 06:  cpu.IP = if (A == 0): B else: (cpu.IP+3)     # JNE
        of 07:  C = (A < B).int;     inc(cpu.IP, 4)          # LESS
        of 08:  C = (A == B).int;    inc(cpu.IP, 4)          # EQUALS
        of 09:  cpu.BP = cpu.BP + A; inc(cpu.IP, 2)          # SET_BASE
        of 99:  cpu.HALTED = true                            # QUIT
        else:   echo "invalid opcode: ", opcodeNumber

# --- Execute a program ---

proc run(cpu:CPU) =
    cpu.IP = 0
    while not cpu.HALTED:
        cpu.execute()

# --- Read and parse data ---

var data = readLines("input_09.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

var cpu = CPU(MEM: data, INPUT: @[1])
cpu.run()
echo "Part 1: ", cpu.OUTPUT.pop

# --- Part 2 ---

cpu = CPU(MEM: data, INPUT: @[2])
cpu.run()
echo "Part 2: ", cpu.OUTPUT.pop
