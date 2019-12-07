import sequtils, strutils, math, tables, algorithm

type Vec = tuple[x,y:int]
type Step = tuple[count:int, dir:Vec]
type WireEnum = enum Wire1, Wire2
type WireSet = set[WireEnum]

proc `+`(a,b:Vec):Vec = (a.x+b.x, a.y+b.y)

proc parseNode(n:string):Step =
    let steps = n[1..^1].parseInt
    case n[0]:
        of 'U': return (steps, (0, -1))
        of 'D': return (steps, (0, 1))
        of 'L': return (steps, (-1, 0))
        of 'R': return (steps, (1, 0))
        else: discard

let wires = toSeq(lines("input_03.txt")).mapIt(it.split(","))
let w1 = wires[0].map(parseNode)
let w2 = wires[1].map(parseNode)

var map = initTable[Vec, var tuple[value:WireSet, steps:int]]()

proc runWire(wire:seq[Step], wireEnum:WireEnum)=
    var pos:Vec = (0,0)
    var steps = 0
    for p in wire:
        for i in 1..p.count:
            pos = pos + p.dir
            steps.inc

            discard map.hasKeyOrPut(pos, ({}, 0)) 
            if map[pos].value != {Wire1, Wire2}:
                map[pos].steps.inc(steps)
            
            map[pos].value.incl(wireEnum)

runWire(w1, Wire1)
runWire(w2, Wire2)
        
let overlaps = toSeq(map.keys).filterIt(map[it].value == {Wire1, Wire2})
echo "Part 1: ", overlaps.mapIt(it.x.abs+it.y.abs).sorted[0]
echo "Part 2: ", overlaps.mapIt(map[it].steps).sorted[0]