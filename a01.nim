import sequtils, strutils, math
var lines = toSeq(lines("input_01.txt")).map(parseInt)

func fuel(x:int):int = floor(x/3).int-2

func fuel2(x:int):int =
    let y = fuel(x)
    if y > 0: y+fuel2(y) else: 0
    

let fuelSum = lines.map(fuel).sum
let fuelSum2 = lines.map(fuel2).sum

echo "Part one: ", fuelSum
echo "Part two: ", fuelSum2
