import random
import csv
import sys

if __name__ == "__main__":
    with open("names.csv", "r") as f:
        reader = csv.reader(f)
        names = []
        used = []
        for row in reader:
            row[1] = bool(int(row[1]))
            if (row[1]):
                used.append(row)
            else:
                names.append(row)

    if (len(names) == 0):
        sys.exit(1)

    idx = random.randint(0,len(names) - 1)
    name = names[idx][0]
    names[idx][1] = True
    print(name)

    with open("names.csv", "w") as f:
        writer = csv.writer(f)
        for row in names:
            row[1] = 1 if row[1] else 0
            writer.writerow(row)
        for row in used:
            row[1] = 1 if row[1] else 0
            writer.writerow(row)
    sys.exit(0)
