import sequtils, strutils, math, tables, sets, algorithm, terminal, os
var dataRaw = toSeq(lines("input_10.txt"))
type Vec = tuple[x,y:float]
type Pol = tuple[angle,dist:float, vec:Vec]

var points:seq[Vec]
var center:Vec
for y in 0..high(dataRaw):
    for x in 0..high(dataRaw[0]):
        if dataRaw[y][x] == '#':
            points.add((x.float, y.float))
        elif dataRaw[y][x] == 'X':
            center = (x.float, y.float)

proc toPolar(points:seq[Vec], center:Vec):seq[Pol] =
    for p in points:
        let x = center.x.float - p.x
        let y = center.y.float - p.y
        let angle  = arctan2(y, x)+math.PI
        let dist = sqrt(x*x + y*y)
        result.add((angle, dist, p))

var maxValue = 0
var maxPoint = points[0]

for p in points:
    let polar = points.toPolar((p.x, p.y))
    var c = initCountTable[float]()
    for p in polar:
        c.inc(p.angle)
    if c.len > maxValue:
        maxValue = c.len
        maxPoint = p
    
echo "Part 1: ", maxValue
center = maxPoint

proc compareAngle(a, b: Pol): int =
    if a.angle < b.angle:
        -1
    else:
        +1


var polar = points.toPolar(center)
polar.sort(compareAngle)

var bucketsTable = initOrderedTable[float, seq[Pol]]()

for p in polar:
    bucketsTable.mgetOrPut(p.angle, @[]).add(p)

#for b in bucketsTable.keys:    echo bucketsTable[b]
var buckets = toSeq(bucketsTable.values)

buckets = buckets.mapIt(it.sortedByIt(it.dist))

var i=0
while buckets[i][0].angle < 3*PI/2:
    inc(i)
var deleteCount = 0

while buckets.concat.len > 0:
    let b = buckets[i]
    if b.len > 0:
        var p = b[0]
        dataRaw[p.vec.y.int][p.vec.x.int] = 'o'
        #echo dataRaw.join("\n") & "\n"
        buckets[i].delete(0)
        deleteCount.inc
        if deleteCount == 200:
            echo p.vec.x*100+p.vec.y
    i = (i + 1) mod buckets.len


