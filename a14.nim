import sequtils, strutils, math, tables, strformat

var data = toSeq(lines("input_14.txt"))

type Node = ref object
    name: string
    baseAmount: int
    numberOfReactionsNeeded:int
    claims:seq[int]
    expectedClaimCount:int
    parents: seq[tuple[node:Node, amount:int]]

proc `$`(node:Node):string =
    fmt"{$node.baseAmount}  {node.name} ({$node.claims.sum} claims) = ({node.parents.mapIt(it[0].name & '*' & $it[1]).join(',' & ' ')})"


# --- Parse data ---

var nodes = initTable[string, Node]()
nodes.add("ORE", Node(name:"ORE", baseAmount: 1))

proc parseRawNode(s:string):tuple[amount:int, name:string] =
    let r = s.split(" ")
    result = (r[0].parseInt, r[1])

for line in data:
    var r = line.split(" => ").mapIt(it.split(", "))
    let input = r[0].map(parseRawNode)
    let output = r[1][0].parseRawNode
    
    let outputNode = nodes.mgetOrPut(output.name, Node(name: output.name))
    outputNode.baseAmount = output.amount

    for x in input:
        var childNode = nodes.mgetOrPut(x.name, Node(name: x.name))
        outputNode.parents.add((childNode, x.amount))
        childNode.expectedClaimCount.inc

# --- Part 1 ---

proc collectClaims(node:Node)=
    for parent in node.parents:
        parent.node.claims.add(parent.amount * node.numberOfReactionsNeeded)
        if parent.node.claims.len == parent.node.expectedClaimCount:
            let totalClaims = parent.node.claims.sum
            parent.node.numberOfReactionsNeeded = ceil(totalClaims/parent.node.baseAmount).int
            collectClaims(parent.node)

proc getOreNeededForFuel(fuel:int):int =
    for node in nodes.mvalues: node.claims = @[]
    nodes["FUEL"].numberOfReactionsNeeded = fuel
    collectClaims(nodes["FUEL"])
    return nodes["ORE"].claims.sum

echo "Part 1: ", getOreNeededForFuel(1)

# --- Part 2 ---

let goalOre = 1000000000000
var fuel = 1
var lastFuel = 0
var stepSize = 2.0
while true:
    let currentOre = getOreNeededForFuel(fuel)
    if currentOre > goalOre:
        fuel = lastFuel
        stepSize = (1 + stepSize) / 2
    else:
        lastFuel = fuel
        fuel = int(fuel.float * stepSize)
        if lastFuel == fuel: break

echo "Part 2: ", fuel
