import random
count = 0
for i in range(1000):
    Mother = random.choice(['Head', 'Tail'])
    Father = random.choice(['Head', 'Tail'])
    Child = random.choice(['Head', 'Tail'])
    if Mother == 'Head' and Father == 'Head' and Child == 'Head':
        count = count +1
print(count);

