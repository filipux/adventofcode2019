import strutils, tables, sets

type Node = ref object
    name:string
    parent:Node
    children:seq[Node]

# --- Read and parse data ---

var nodes:Table[string, Node]

for line in lines("input_06.txt"):
    var orbs = line.split(')')
    let (inner, outer) = (orbs[0], orbs[1])
    var innerNode = nodes.mgetOrPut(inner, Node(name:inner))
    var outerNode = nodes.mgetOrPut(outer, Node(name:outer))
    outerNode.parent = innerNode
    innerNode.children.add(outerNode)
    
# --- Part 1 ---

proc countOrbits(node:Node, count:int = 0):int =
    result = count
    for child in node.children:
        result += countOrbits(child, count + 1)

echo "Part 1: ", countOrbits(nodes["COM"])

# --- Part 2 ---

proc getParents(node:Node):seq[string] =
    var p = node;
    while p.parent != nil:
        p = p.parent
        result.add(p.name)

let p1 = nodes["YOU"].getParents.toHashSet
let p2 = nodes["SAN"].getParents.toHashSet
let minOrbits = (p2 -+- p1).len
echo "Part 2: ", minOrbits