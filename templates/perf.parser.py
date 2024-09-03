import csv
import argparse

unit = {
    "cpu-clock": "ms",
    "context-switches": "M/s",
    "cpu-migrations": "K/s",
    "page-faults": "K/s",
    "cycles": "GHz",
    "instructions": "ins per cycle",
    "branches": "M/s",
    "branch-misses": "% of all branches",
    "L1-dcache-loads": "M/s",
    "L1-dcache-load-misses": "% of all L1-dcache hits",
    "LLC-loads": "M/s",
    "LLC-load-misses": "% of all LL-cache hits"
}

def check_line(line:str) -> bool:
    return len(line.strip()) != 0

def format_line(line: str):
    # if not check_line(line):
    #     return
    res = line.split()
    if res[0] == "CPU":
        res.append("UNIT")
    else:
        res.append(unit[res[-1]])
    return res

parser = argparse.ArgumentParser()

if __name__ == "__main__":
    parser.add_argument('-i', '--input', default="./perf.data")
    parser.add_argument('-o', '--output', default="output.csv")
    # parser.add_argument('-f', '--functions', default="trace.functions")

    args = parser.parse_args()
    raw_file = args.input
    lines = []
    res = []
    csv_output = args.output
    # function_file = args.functions

    # function_name = get_function_name(function_file)

    with open(raw_file, "r") as file:
        # for i in range(3):
        #     file.readline()
        lines = file.readlines()
        for line in lines:
            # print(len(line.strip()))
            new_line = format_line(line)
            if new_line is not None:
                res.append(new_line)
        # for line in res:
        #     print(line)

    with open(csv_output, "w") as file:
        csv_writer = csv.writer(file)
        csv_writer.writerow(res[0])
        csv_writer.writerows(res[1:])

