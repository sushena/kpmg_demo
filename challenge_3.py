def findkeys(node, kv):
    try:
        if isinstance(node, list):
            for i in node:
                if isinstance(i, dict):
                    for x in findkeys(i, kv):
                        return x
        elif isinstance(node, dict):
            if kv in node:
                return node[kv]
            for j in node.values():
                return findkeys(j, kv)
                # for x in findkeys(j, kv):
                #     return x
    except Exception as e:
        pass


d = {"a":{"b":["c","d"], "Z":{'a','b'}}}
g = findkeys(d, 'b')
if g is None:
    print('Key Missing')
else:
    print(g)
