#! /usr/bin/python3
import argparse

def save_in_tmp(core_idx, data):
    temp_file = f"tmp-{core_idx}"
    with open(temp_file, "w") as f:
        f.write(data)

def load_from_tmp(core_idx) -> str:
    with open(f"tmp-{core_idx}") as f:
        content = f.readline().strip()
    return content
    
# Format:
# for functions:
# core_id, duration, function
#
# for napi_poll event
# core_id, event, device, work, budget 
def parse_line(line: str):
    if line.startswith("#"):
        return
    if line.startswith(" -"):
        return
    line = line.split()

    if len(line) < 3:
        return

    # case napi_poll: line[3] == "napi_poll:"
    if line[3] == "napi_poll:":
        core_idx = line[0][:-1]
        event = "napi_poll"
        device = line[12]
        work = line[14]
        budget = line[16]
        return [event,core_idx,device,work,budget]
        # return f"{core_idx},{device},{work},{budget}"
    
    # case function:
    # Three subcases:
    # subcase 1: function : core_idx, duration, dummy_function();
    # subcase 2: function_start: core_idx, dummy_function() {
    # subcase 3: function_end: core_idx, duration, }
    # subcase 3-a: function_end: core_idx, duration, }, /* dummy_function */
    
    if line[-1] == "{": # subcase 2
        core_idx = line[0][:-1]
        function_name = line[2]
        save_in_tmp(core_idx, function_name)
        return
    
    if line[-1][-1] == ";": # subcase 1
        core_idx = line[0][:-1]
        offset = 0 if line[2] == "us" else 1
        duration = line[1+offset]
        function_name = line[4+offset]
        return [function_name,core_idx,duration]

    if (line[2] == "us" and line[4] == "}") or (line[3] == "us" and line[5] == "}"):
        core_idx = line[0][:-1]
        offset = 0 if line[2] == "us" else 1
        duration = line[1+offset]
        if line[-1] == '}': # subcase 3
            function_name = load_from_tmp(core_idx)
        else: # subcase 3-a
            function_name = line[6+offset]
        return [function_name,core_idx,duration]

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input-file", default="trace.dat", help="The path of the file to parse")
parser.add_argument("-o", "--output-dir", default=".", help="The directory where the output files are stored")
args = parser.parse_args()

if __name__ == "__main__":
    funcgraph_file = open(f"{args.output_dir}/functrace.csv", "w")
    napi_file = open(f"{args.output_dir}/napi.csv", "w")
    funcgraph_file.write("function,core_id,duration\n")
    napi_file.write("core_id,device,work,budget\n")
    
    with open(args.input_file) as f:
        line = f.readline()
        while line != "":
            res = parse_line(line.strip())
            if res is not None:
                if res[0] == "napi_poll":
                    val = ",".join(res[1:])
                    napi_file.write(f"{val}\n")
                else:
                    val = ",".join(res)
                    funcgraph_file.write(f"{val}\n")
            line = f.readline()
