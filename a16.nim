import sequtils, strutils, tables, math, algorithm

var data = toSeq(toSeq(lines("input_16.txt"))[0].items).mapIt(parseInt($it))

proc `.*`(a,b:seq[int]):int=
    for i in 0..high(a):
        result.inc(a[i] * b[i])

proc toInt(nums:seq[int]):int=
    var p = 1
    for num in nums.reversed:
        result.inc(num * p)
        p = p * 10


proc getPatternDigit(offset:int, phaseIndex:int):int =
    const basePattern = @[0, 1, 0, -1]
    basePattern[((offset + 1) div (phaseIndex + 1)) mod 4]
    
proc getPattern(phaseIndex:int, len:int):seq[int] =
    for i in 0..len-1:
        result.add(getPatternDigit(i, phaseIndex))

proc phase(signal:seq[int]):seq[int] =
    result = signal
    for i in 0..high(signal):
        result[i] =  abs(signal .* getPattern(i, signal.len)) mod 10

# --- Part 1 ---

#var signal = @[1,2,3,4,5,6,7,8]
#signal = @[8,0,8,7,1,2,2,4,5,8,5,9,1,4,5,4,6,6,1,9,0,8,3,2,1,8,6,4,5,5,9,5]
var signal = data

for i in 1..100:
    signal = phase(signal)
    
echo "Part 1: ", signal[0..7].toInt

# --- Part 2 ---
signal = data
var offset = signal[0..6].toInt
echo offset

