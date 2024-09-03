#! /usr/bin/python3
import argparse

context = {}
line_number = 0

def save_ctx(core_idx, data):
    context[core_idx] = data

def load_ctx(core_idx):
    return context.get(core_idx)
    
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
    res = line.split("|")

    if len(res) < 2:
        return
    
    prefix, suffix = res
    
    # Prefix parsing: format= " %d) [[+!]? %.2f us]?    "
    core_id, duration = prefix.strip().split(")")
    duration = duration.split()
    if len(duration) >= 1:
        duration = duration[-2]

    # case napi_poll: suffix[1] == "napi_poll:"
    suffix = suffix.split()
    # print(line_number, suffix)
    
    if suffix[0] == "/*":
        event = "napi_poll"
        napi_struct = suffix[7]
        device = suffix[10]
        work = suffix[12]
        budget = suffix[14]
        if device.startswith("wg"):
            duration = load_ctx(core_id)
        else:
            duration = ""
        return [event,core_id,device,napi_struct,work,budget,duration]
        
    elif suffix[-1] != "{":
        duration = str(duration)
        save_ctx(core_id, duration)
        return ["wg_packet_rx_poll", core_id, duration]

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input-file", default="trace.dat", help="The path of the file to parse")
parser.add_argument("-o", "--output-dir", default=".", help="The directory where the output files are stored")
args = parser.parse_args()

if __name__ == "__main__":
    funcgraph_file = open(f"{args.output_dir}/functrace.csv", "w")
    napi_file = open(f"{args.output_dir}/napi.csv", "w")
    funcgraph_file.write("function,core_id,duration\n")
    napi_file.write("core_id,device,napi_struct,work,budget,duration\n")
    
    with open(args.input_file) as f:
        line = f.readline()
        line_number += 1
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
            line_number += 1
