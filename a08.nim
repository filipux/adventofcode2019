import sequtils, strutils, algorithm

# --- Read layers ---

var pixels = readLines("input_08.txt")[0].mapIt(parseInt($it))
var layers = pixels.distribute(pixels.len div (25*6))

# --- Part 1 ---

let zeros = layers.mapIt(it.count(0))
let minZeroIndex = zeros.find(zeros.min)
let minZeroLayer = layers[minZeroIndex]
echo "Part 1: ", minZeroLayer.count(1) * minZeroLayer.count(2)

# --- Part 2 ---

var pic = layers[0]
for layer in layers.reversed:
    for i, p in layer:
        pic[i] = if p != 2: p else: pic[i]

echo "Part 2:"
for row in pic.distribute(6):
    echo row.mapIt(chr(it*3+32)).join
