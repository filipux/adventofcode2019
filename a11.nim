import sequtils, strutils, tables, Math, terminal

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

var data = readLines("input_11.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

type Vec = tuple[x,y:int]
type Paint = enum Black = ".", White = "#"
type Direction = enum Right, Down, Left, Up
type Robot = tuple[pos: Vec, dir: Direction]

proc turnLeft(robot:var Robot) =
    case robot.dir:
        of Right: robot.dir = Up
        of Down: robot.dir = Right
        of Left: robot.dir = Down
        of Up: robot.dir = Left

proc turnRight(robot:var Robot) =
    robot.turnLeft
    robot.turnLeft
    robot.turnLeft

proc forward(robot:var Robot) =
    case robot.dir:
        of Right:robot.pos.x.inc
        of Down: robot.pos.y.inc
        of Left: robot.pos.x.dec
        of Up:   robot.pos.y.dec

proc `$`(grid:Table[Vec, Paint]):string = 
    let keys = toSeq(grid.keys)
    let minX = keys.mapIt(it.x).min
    let maxX = keys.mapIt(it.x).max
    let minY = keys.mapIt(it.y).min
    let maxY = keys.mapIt(it.y).max
    for y in minY..maxY:
        for x in minX..maxX:
            result &= $grid.getOrDefault((x,y), Black)
        result.add("\n")

proc getSolution(startColor:Paint):(int, string) =   
    var cpu = CPU(MEM: data)
    var robot = (pos:(0,0), dir:Up)
    var grid = initTable[Vec, Paint]()
    var painted = initTable[Vec, bool]()
    grid[robot.pos] = startColor
    while not cpu.HALTED:
        let paint = grid.mgetOrPut(robot.pos, Black)
        cpu.INPUT.add(paint.int)
        
        while cpu.OUTPUT.len == 0 and not cpu.HALTED: cpu.execute()
        if cpu.HALTED: break

        grid[robot.pos] = Paint(cpu.OUTPUT[0])
        painted[robot.pos] = true
        cpu.OUTPUT = @[]
        
        while cpu.OUTPUT.len == 0 and not cpu.HALTED: cpu.execute()
        if cpu.HALTED: break
        
        if cpu.OUTPUT[0] == 0: robot.turnLeft
        if cpu.OUTPUT[0] == 1: robot.turnRight
        cpu.OUTPUT = @[]

        robot.forward
    return (toSeq(painted.keys).len, $grid)

echo "Part 1: ", getSolution(Black)[0]
echo "Part 2: \n", getSolution(White)[1]