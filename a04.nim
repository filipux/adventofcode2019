const numMin = 402328;
const numMax = 864247;

var nums1:seq[int]
var nums2:seq[int]

for a in 0..9:
    for b in a..9:
        for c in b..9:
            for d in c..9:
                for e in d..9:
                    for f in e..9:
                        let num = a*100000+b*10000+c*1000+d*100+e*10+f
                        if num >= numMin and num <= numMax:
                            if a==b or b==c or c==d or d==e or e==f:
                                nums1.add(num)
                            if (a==b and b != c) or (b==c and c != d and a != b) or (c==d and d != e and b != c) or (d==e and e != f and c != d) or (e==f and d != e):
                                nums2.add(num)         

echo nums1.len
echo nums2.len
