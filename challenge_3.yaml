def findkeys(ojet, kv):
    try:
        if isinstance(ojet, list):
            for i in ojet:
                if isinstance(i, dict):
                    for x in findkeys(i, kv):
                        return x
        elif isinstance(ojet, dict):
            if kv in ojet:
                return ojet[kv]
            for j in ojet.values():
                for x in findkeys(j, kv):
                    return x
    except Exception as e:
        pass


#d = {"a":{"b":{"c":"d"}}}
#d = {"x":{"y":{"z":"a"}}}
d = {"x":{"y":["z","a"]}}
g = findkeys(d, 'y')
if g is None:
    print('Key Missing')
else:
    print(g)
