import sequtils, strutils

# --- Memory and registers ---

type CPU = ref object
    MEM:seq[int64]
    INPUT:seq[int64]
    IP:int64
    BP:int64
    HALTED:bool
    OUTPUT:seq[int64]

# --- int64 helper converter ---

# int is already int64 on osx but why not...
converter seqIntToInt64(x:seq[int]): seq[int64] = x.mapIt(it.int64)

# --- Helper functions and templates ---

proc ensureCapacity(self:var seq[int64], address:int64) =
    self.setLen(1 + max(self.len, address))

proc getMemoryAddress(cpu:CPU, offset:int64):int64=
    let opcodeOffset = [0,100,1000,10000][offset]
    let mode = cpu.MEM[cpu.IP] div opcodeOffset mod 10
    case mode:
        of 0: result = cpu.MEM[cpu.IP + offset]
        of 1: result = cpu.IP + offset
        of 2: result = cpu.MEM[cpu.IP + offset] + cpu.BP
        else: assert(false)
        
template A():int64 =
    var address = getMemoryAddress(cpu, 1)
    cpu.MEM.ensureCapacity(address)
    cpu.MEM[address]

template B():int64 =
    var address = getMemoryAddress(cpu, 2)
    cpu.MEM.ensureCapacity(address)
    cpu.MEM[address]
    
template C():int64 = 
    var address = getMemoryAddress(cpu, 3)
    cpu.MEM.ensureCapacity(address)
    cpu.MEM[address]

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
