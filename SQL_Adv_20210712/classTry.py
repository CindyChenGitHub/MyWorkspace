import random
count = 0
for i in range(1000):
    Mom = random.choice(['head', 'tail'])
    Dad = random.choice(['head', 'tail'])
    Child = random.choice(['head', 'tail'])
    if Mom == 'head' and Dad == 'head' and Child =='head':
        count = count + 1
print(count);