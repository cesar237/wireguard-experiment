import csv
import argparse

def read_line(line: str):
    pass

def check_line(line:str) -> bool:
    return len(line.split()) in [6, 9]

def get_function_name(function_file_path: str) -> dict:
    res = {}
    with open(function_file_path) as file:
        lines = file.readlines()
        for line in lines:
            line = line.split()
            func_code, func_name = line[:2]
            func_code = int(func_code, base=16)
            res[func_code] = func_name
    return res

def format_line(line: str, function_name: dict):
    if not check_line(line):
        return
    line = line.split()
    res = []
    res.append(line[0])
    res.append(int(line[1][1:-1]))
    res.append(float(line[2][:-1]))
    res.append(line[3][:-1])
    res.append(function_name[int(line[4][5:], base=16)])
    if len(line) == 6:
        res.append(int(line[5].split("=")[1]))
        res.append(None)
    else:
        calltime = int(line[5].split("=")[1], base=16)
        rettime = int(line[6].split("=")[1], base=16)
        res.append(int(line[8].split("=")[1]))
        res.append(rettime-calltime)
    return res

parser = argparse.ArgumentParser()

if __name__ == "__main__":
    parser.add_argument('-i', '--input', default="./trace.raw")
    parser.add_argument('-o', '--output', default="output.csv")
    parser.add_argument('-f', '--functions', default="trace.functions")

    args = parser.parse_args()
    raw_file = args.input
    lines = []
    res = []
    csv_output = args.output
    function_file = args.functions
    header = ["Thread","CPU","Timestamp","event_type","Function","Depth","Duration"]
    csv_file = open(csv_output, "w")
    csv_writer = csv.writer(csv_file)
    csv_writer.writerow(header)

    function_name = get_function_name(function_file)

    with open(raw_file, "r") as file:
        line = file.readline()
        while line != "":
            new_line = format_line(line, function_name)
            if new_line is not None:
                csv_writer.writerow(new_line)
            line = file.readline()
        # for line in res:
        #     print(line)
    csv_file.close()
    # with open(csv_output, "w") as file:
    #     csv_writer = csv.writer(file)
    #     csv_writer.writerow(header)
    #     csv_writer.writerows(res)

