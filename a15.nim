import sequtils, strutils, math, tables, deques, sets

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

var data = readLines("input_15.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

type Unit = enum Unknown = " ", Wall = "#", Space = ".", OxygenSystem = "X"
type Direction = enum North = 1, South, West, East
type MoveResult = enum HitWall, Moved, Oxygen
type Pos = tuple[x,y:int]

proc makeMove(droid:Pos, move:Direction):Pos =
    case move:
        of North:   (droid.x, droid.y + 1)
        of South:   (droid.x, droid.y - 1)
        of West:    (droid.x - 1, droid.y)
        of East:    (droid.x + 1, droid.y)  

proc turnLeft(move:Direction):Direction =
    case move:
        of North:  West
        of South:  East
        of West:   South
        of East:   North

proc turnRight(move:Direction):Direction =
    case move:
        of North:  East
        of South:  West
        of West:   North
        of East:   South

proc `$`(grid:Table[Pos, Unit]):string = 
    let keys = toSeq(grid.keys)
    let minX = keys.mapIt(it.x).min
    let maxX = keys.mapIt(it.x).max
    let minY = keys.mapIt(it.y).min
    let maxY = keys.mapIt(it.y).max
    for y in minY..maxY:
        for x in minX..maxX:
            result &= $grid.getOrDefault((x,y), Unknown)
        result.add("\n")

# --- Create map ---

var map = initTable[Pos,Unit]()
var droid:Pos
var move = North

var cpu = CPU(MEM: data, INPUT: @[move.int])
while cpu.STATE != Halted:
    cpu.execute()

    if cpu.OUTPUT.len > 0:
        var posAfterMove = droid.makeMove(move)
        case MoveResult(cpu.OUTPUT.pop):
            of HitWall:
                map[posAfterMove] = Wall
                move = move.turnRight
                cpu.INPUT = @[move.int]
            of Moved:
                map[posAfterMove] = Space
                move = move.turnLeft
                cpu.INPUT = @[move.int]
                
                droid = posAfterMove
                if droid == (0,0): break
            of Oxygen:
                map[posAfterMove] = OxygenSystem
                cpu.INPUT = @[move.int]
                droid = posAfterMove

# --- Find shortest path ---
type QueueNode = tuple[pos:Pos, dist:int]

proc findInMap(start:Pos, goal:Unit):QueueNode=
    # We start from the source cell and calls BFS procedure.
    # We maintain a queue to store the coordinates of the matrix and initialize it with the source cell.
    var cell:QueueNode
    var q = initDeque[QueueNode]()
    q.addLast((start, 0))

    # We also maintain a Boolean array visited of same size as our input matrix and initialize all its elements to false.
    var visited = initHashSet[Pos]()
    # We LOOP till queue is not empty
    while q.len > 0:
        # Dequeue front cell from the queue
        cell = q.popFirst()
        # Return if the destination coordinates have reached.
        if map[cell.pos] == goal:
            return cell
        # For each of its four adjacent cells, if the value is 1 and they are not visited yet,
        # we enqueue it in the queue and also mark them as visited.
        let adjacentPos = @[cell.pos.makeMove(North),
                            cell.pos.makeMove(South),
                            cell.pos.makeMove(West),
                            cell.pos.makeMove(East)]
        for adj in adjacentPos:
            if map.hasKey(adj) and map[adj] != Wall and not visited.contains(adj):
                q.addLast((adj, cell.dist + 1))
                visited.incl(adj)
    return cell      


let oxygen = findInMap((0,0), OxygenSystem)
echo "Part 1: ", oxygen.dist

let lastOxygen = findInMap(oxygen.pos, Unknown)
echo "Part 2: ", lastOxygen.dist