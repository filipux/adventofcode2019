import sequtils, strutils, math, tables, deques, sets, algorithm

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
                    A = cpu.INPUT[0];cpu.INPUT.delete(0);   inc(cpu.IP, 2)      # .
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

var data = readLines("input_17.txt")[0].split(",").map(parseInt)

# --- Part 1 ---

type Unit = enum Unknown = " ", Wall = "#", Space = ".", OxygenSystem = "X"
type Direction = enum Up = "^", Left = "<", Right = ">", Down = "v"
type Pos = tuple[x,y:int]

proc makeMove(pos:Pos, move:Direction):Pos =
    case move:
        of Up:   (pos.x, pos.y - 1)
        of Down:   (pos.x, pos.y + 1)
        of Left:    (pos.x - 1, pos.y)
        of Right:    (pos.x + 1, pos.y)


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

var mapString:string

var cpu = CPU(MEM: data)
while cpu.STATE != Halted:
    cpu.execute()
    if cpu.OUTPUT.len > 0:
        mapString &= chr(cpu.OUTPUT.pop)

var map = mapString.split("\n").filterIt(it.len > 0)

# --- Part 1 ---

var total = 0
for y in 1..(map.len-2):
    for x in 1..(map[0].len-2):
        if map[y][x] == '#' and map[y-1][x] == '#' and map[y+1][x] == '#' and map[y][x-1] == '#' and map[y][x+1] == '#':
            total.inc(x*y)

echo "Part 1: ", total

# --- Part 2 ---

type Droid = tuple[pos: Pos, dir:Direction]

proc forward(droid:Droid):Droid =
    result = droid
    result.pos = droid.pos.makeMove(droid.dir)

proc turnLeft(droid:Droid):Droid =
    result = droid
    result.dir = case droid.dir:
        of Up:  Left
        of Down:  Right
        of Left:   Down
        of Right:   Up

proc turnRight(droid:Droid):Droid = droid.turnLeft.turnLeft.turnLeft

proc isValid(droid:Droid):bool = 
    if droid.pos.y in (0..map.high) == false: return false
    if droid.pos.x in (0..map[0].high) == false: return false
    return map[droid.pos.y][droid.pos.x] != '.'

var droid: Droid

for y in 0..map.high:
    for x in 0..map[0].high:
        if map[y][x] == '^':
            droid.pos = (x,y)
            droid.dir = parseEnum[Direction]($map[y][x])

var steps:seq[string]
var forwardSteps = 0
while true:

 
    if droid.forward.isValid:
        droid = droid.forward
        forwardSteps.inc

    elif droid.turnLeft.forward.isValid:
        if forwardSteps > 0:
            steps.add($forwardSteps)
        forwardSteps = 1
        droid = droid.turnLeft.forward
        steps.add("L")
    elif droid.turnRight.forward.isValid:
        if forwardSteps > 0:
            steps.add($forwardSteps)
        forwardSteps = 1
        droid = droid.turnRight.forward
        steps.add("R")
    else:
        steps.add($forwardSteps)
        break
    map[droid.pos.y][droid.pos.x] = ($droid.dir)[0]
#echo map.join("\n")



proc replacePattern[T](data:seq[T], pattern:seq[T], replaceWith:T):seq[T] =
    var i = 0
    var endPos = pattern.len - 1
    while i <= data.high:
        if (endPos <= data.high) and (data[i..endPos] == pattern):
                result.add(replaceWith)
                i.inc(pattern.len)
        else:
            result.add(data[i])
            i.inc
        endPos = i + pattern.len - 1
    

proc getABC(steps:seq[string]):tuple[A,B,C:seq[string]]=
    for i in 1..10:
        var A = steps[0..i-1]
        var rep = replacePattern(steps, A, "A")
        for j in 1..10:
            var g = 0
            while rep[g] == "A": g.inc
            var B = rep[g..j-1+g]
            # WHAT IS HAPPENING???
            var rep = replacePattern(rep, B, "B")
            var r = rep.join(",").split({'A','B'}).mapIt(it.replace(",","")).filterIt(it.len > 0)
            # ...I DON'T EVEN...
            var t = r.sortedByIt(it.len)[0]
            for k in 0..(t.high):
                var c_mer = t[0..k]
                # HOW CAN THIS WORK??????
                var b = r.mapIt(it.replace(c_mer, "C")).join("").replace("C", "")
                # IS THIS MACHINE LEARNING????
                var C = c_mer.replace("R", ",R,").replace("L", ",L,").replace(",,", ",").split(",").filterIt(it.len > 0)
                if b.len == 0:
                    return (A,B,C)
                    

        
var abc = getABC(steps)
#echo abc.A.join(",")
var moves = steps.replacePattern(abc.A, "A").replacePattern(abc.B, "B").replacePattern(abc.C, "C")
var debug = "n"

var program = @[moves.join(","), abc.A.join(","), abc.B.join(","), abc.C.join(","), debug]






cpu = CPU(MEM: data)
cpu.MEM[0] = 2
cpu.INPUT = program
            .mapIt(it & chr(10))
            .join("")
            .mapIt(ord(it))
#echo cpu.INPUT
while cpu.STATE != Halted:
    cpu.execute()
    if cpu.OUTPUT.len > 0:
        let v = cpu.OUTPUT.pop
        if v < 256:
            discard#stdout.write chr(v)
        else:
            echo "Part 2: ", v
    if cpu.STATE == Paused:
        echo "PAUSEd" 