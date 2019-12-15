import sequtils, strutils, terminal, os, math

# --- Memory and registers ---

type CPUState = enum Running, Halted, Paused
type CPU = ref object
    MEM:seq[int]
    INPUT:seq[int]
    IP:int
    BP:int
    STATE:CPUState
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
        of 03:
                cpu.STATE = Running                          # POP_INPUT
                if cpu.INPUT.len > 0:                        # .
                    A = cpu.INPUT.pop;   inc(cpu.IP, 2)      # .
                else:                                        # .
                    cpu.STATE = Paused                       # .
        of 04:  cpu.OUTPUT.add(A);   inc(cpu.IP, 2)          # PUSH_OUTPUT
        of 05:  cpu.IP = if (A != 0): B else: (cpu.IP+3)     # JE
        of 06:  cpu.IP = if (A == 0): B else: (cpu.IP+3)     # JNE
        of 07:  C = (A < B).int;     inc(cpu.IP, 4)          # LESS
        of 08:  C = (A == B).int;    inc(cpu.IP, 4)          # EQUALS
        of 09:  cpu.BP = cpu.BP + A; inc(cpu.IP, 2)          # SET_BASE
        of 99:  cpu.STATE = HALTED                            # QUIT
        else:   echo "invalid opcode: ", opcodeNumber

# --- Execute a program ---

proc run(cpu:CPU) =
    cpu.IP = 0
    while cpu.STATE != Halted:
        cpu.execute()

# --- Read and parse data ---

var data = readLines("input_13.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

var points = 0

# Emoji works fine in VS.code terminal
type Tile = enum Empty=" ", Wall="💧", Block="👛", Paddle="🏓", Ball="🎾"

type Screen = seq[seq[Tile]]

proc `$`(screen:Screen):string=
    result = "\n" & $points & " points\n"
    result &= screen.mapIt(it.mapIt($it).join("")).join("\n")

proc pos(screen:Screen, tile:Tile):tuple[x:int, y:int] =
    for y in 0..high(screen):
        for x in 0..high(screen[y]):
            if screen[y][x] == tile:
                return (x, y)

proc playGame(cpu:CPU):Screen =
    result = newSeqWith(24, newSeq[Tile](42))
    
    while cpu.STATE != Halted:
        cpu.execute()

        # Joystick handling
        if cpu.STATE == PAUSED:
            let paddleX = result.pos(Paddle).x
            let ballX = result.pos(Ball).x
            cpu.INPUT = @[sgn(ballX - paddleX)]
            
            terminal.eraseScreen()
            echo $result
            sleep(70)

        # Screen output handling
        if cpu.OUTPUT.len == 3:
            let x = cpu.OUTPUT[0]
            let y = cpu.OUTPUT[1]
            let tile = cpu.OUTPUT[2]
            if x == -1 and y == 0:
                points = tile.int
            else:
                result[y][x] = Tile(tile)
            cpu.OUTPUT = @[]
        
var cpu = CPU(MEM: data)
cpu.MEM[0] = 2
var screen = playGame(cpu)
echo screen    
