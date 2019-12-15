import sequtils, strscans, strformat, math

type Moon = tuple[x,y,z:int, dx,dy,dz:int, name:string]

proc `$`(moon:Moon):string=
    fmt"(pos({moon.x}, {moon.y}, {moon.z}), vel({moon.dx}, {moon.dy}, {moon.dz}) = {moon.name})"

proc loadMoons():seq[Moon]=
    const moonNames = ["Io", "Europa", "Ganymede","Callisto"]
    proc parseCoordinates(s:string):(int,int,int)=
        var x, y, z: int
        discard scanf(s, "<x=$i, y=$i, z=$i>", x, y, z)
        return (x,y,z)
    var data = toSeq(lines("input_12.txt")).map(parseCoordinates)
    for i in 0..3:
        result.add((x:data[i][0], y:data[i][1], z:data[i][2], dx: 0, dy: 0, dz: 0, name: moonNames[i]))


# --- Part 1 ---

var moons = loadMoons()   

func timestep(moons:seq[Moon]):seq[Moon] =
    result = moons
    for i in 0..high(result):
        for j in (i+1)..high(result):
            var m1 = result[i]
            var m2 = result[j]

            #Gravity 
            if m2.x > m1.x:
                m1.dx.inc
                m2.dx.dec
            if m2.y > m1.y:
                m1.dy.inc
                m2.dy.dec
            if m2.z > m1.z:
                m1.dz.inc
                m2.dz.dec
            
            if m2.x < m1.x:
                m2.dx.inc
                m1.dx.dec
            if m2.y < m1.y:
                m2.dy.inc
                m1.dy.dec
            if m2.z < m1.z:
                m2.dz.inc
                m1.dz.dec

            result[i] = m1
            result[j] = m2
            
    for m in result.mitems:
        m.x.inc(m.dx)
        m.y.inc(m.dy)
        m.z.inc(m.dz)
    
proc pot(moon:Moon):int = return abs(moon.x)+abs(moon.y)+abs(moon.z)
proc kin(moon:Moon):int = return abs(moon.dx)+abs(moon.dy)+abs(moon.dz)


for i in 0..999:
    moons = timestep(moons)

echo "Part 1: ", moons.mapIt(pot(it) * kin(it)).sum

# --- Part 2 ---

proc getCycles():tuple[x:int, y:int, z:int]=
    var moons = loadMoons()
    let originalX = moons.mapIt(it.x) & moons.mapIt(it.dx)
    let originalY = moons.mapIt(it.y) & moons.mapIt(it.dy)
    let originalZ = moons.mapIt(it.z) & moons.mapIt(it.dz)
    var i = 0 
    while true:
        moons = timestep(moons)
        i.inc

        let keyX = moons.mapIt(it.x) & moons.mapIt(it.dx)
        let keyY = moons.mapIt(it.y) & moons.mapIt(it.dy)
        let keyZ = moons.mapIt(it.z) & moons.mapIt(it.dz)

        if keyX == originalX and result.x == 0: result.x = i
        if keyY == originalY and result.y == 0: result.y = i
        if keyZ == originalZ and result.z == 0: result.z = i
        if result.x > 0 and result.y > 0 and result.z > 0: break

        
proc lcm(a,b,c:int):int=
    lcm(lcm(a,b),c)

var cycles = getCycles()
echo "Part 2: ", lcm(cycles.x, cycles.y, cycles.z)
