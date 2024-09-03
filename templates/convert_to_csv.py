import pandas as pd
from matplotlib import pyplot as plt
from itertools import product
import argparse
from multiprocessing import Pool
import os

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--cores", nargs='+', required=True, help="List of values for CPU core to analyse")
parser.add_argument("-n", "--flows", nargs='+', required=True, help="List of values for the number of flows to analyse")
parser.add_argument("-f", "--concurrent", type=int, help="Number of concurrent processes", default=10)
parser.add_argument("-d", "--results", help="The path to the results", default="/tmp/results")
parser.add_argument("-w", "--wireguard-activated", action="store_true", default=False)

args = parser.parse_args()
cores = args.cores
flows = args.flows

cases = product(cores, flows)

# cores = len([directory for directory in os.listdir() if os.path.isdir(directory) and not directory.startswith(".") ])
# cores = list(range(1, cores))
os.chdir(args.results)


def read_sar_csv(cpu, number_of_flows):
    sar_cpu = pd.read_csv(f"CPU-{cpu}/nflow-{number_of_flows}/sar/sar.cpu.csv", sep=";")
    sar_cpu = sar_cpu[sar_cpu["CPU"] == -1]
    sar_memory = pd.read_csv(f"CPU-{cpu}/nflow-{number_of_flows}/sar/sar.memory.csv", sep=";")
    sar_network = pd.read_csv(f"CPU-{cpu}/nflow-{number_of_flows}/sar/sar.network.csv", delimiter=";", on_bad_lines="skip")
    return sar_cpu, sar_memory, sar_network

def serialize_sar(data, columns, cpus, nflows):
    dataset = data[columns]
    data_median = dataset.median()
    data_std = dataset.std()

    df = pd.DataFrame(data_median).T
    df["CPU"] = cpus
    df["Number of flows"] = nflows

    df_std = pd.DataFrame(data_std).T
    df_std["CPU"] = cpus
    df_std["Number of flows"] = nflows

    return df, df_std

def get_network_data(sar_network, physical_interface, wireguard_interface, cpus, nflows):
    dataset_phy = sar_network[sar_network["IFACE"] == physical_interface].reset_index(drop=True)
    dataset_wg = sar_network[sar_network["IFACE"] == wireguard_interface].reset_index(drop=True)
    
    wg_data, _ = serialize_sar(dataset_wg, ["rxpck/s", "txpck/s", "rxkB/s", "txkB/s"], cpus, nflows)
    phy_data, _ = serialize_sar(dataset_phy, ["rxpck/s", "txpck/s", "rxkB/s", "txkB/s", "%ifutil"], cpus, nflows)
    
    phy_data["IFACE"] = physical_interface
    wg_data["IFACE"] = wireguard_interface
    
    return pd.concat([phy_data, wg_data], axis=0)

def read_perf_csv(cpu, nflows):
    perf_output = pd.read_csv(f"CPU-{cpu}/nflow-{nflows}/perf/perf.csv") 
    return perf_output

def get_perf_data_per_cpu(perf_output, cpu, ncpus, nflows):
    # Compute the total time from data
    total_time = perf_output["TIME"][0]
    total_time /= 10**9

    perf_output = perf_output[perf_output["CPU"] == cpu]
    
    # Format the event names
    perf_output["EVENT"] = perf_output["EVENT"].apply(lambda row: row.replace("-", "_"))

    # Transform to json
    res = {}
    units = {}
    for _, val in perf_output.iterrows():
        res[val["EVENT"]] = {
            "val": val["VAL"],
#             "unit": val["UNIT"],
#             "Core": val["CPU"]
        }
        units[val["EVENT"]] = {
#             "val": val["VAL"],
            "unit": val["UNIT"],
#             "Core": val["CPU"]
        }

    # Compute values according to their unit
    # cpu clock
    res["cpu_clock"]["val"] /= 10**6

    # LLC loads and misses
    res["LLC_load_misses"]["val"] /= res["LLC_loads"]["val"] / 100
    res["LLC_loads"]["val"] /= total_time
    res["LLC_loads"]["val"] /= 1_000_000

    # context switches
    res["context_switches"]["val"] /= total_time
    res["context_switches"]["val"] /= 1_000_000

    # cpu migration
    res["cpu_migrations"]["val"] /= total_time
    res["cpu_migrations"]["val"] /= 1_000

    # page faults
    res["page_faults"]["val"] /= total_time
    res["page_faults"]["val"] /= 1_000

    # instructions and cycles
    res["instructions"]["val"] /= res["cycles"]["val"]
    res["cycles"]["val"] /= (total_time * 10**9)

    # branches and branch misses
    res["branch_misses"]["val"] /= res["branches"]["val"] / 100
    res["branches"]["val"] /= total_time
    res["branches"]["val"] /= 1_000_000

    # L1 dcache loads and misses
    res["L1_dcache_load_misses"]["val"] /= res["L1_dcache_loads"]["val"] / 100
    res["L1_dcache_loads"]["val"] /= total_time
    res["L1_dcache_loads"]["val"] /= 1_000_000

    df = pd.DataFrame.from_dict(res)
    df["Number of cores"] = ncpus
    df["Number of flows"] = nflows
    df["CPU"] = cpu

    units = pd.DataFrame.from_dict(units)

    return df, units

def get_perf_data(perf_data, ncpus, nflows):
    cores = set(perf_data["CPU"])
    res = []
    units = None
    for val in cores:
        data, units = get_perf_data_per_cpu(perf_data, val, ncpus, nflows)
        res.append(data)
    return pd.concat(res), units

def read_trace_csv(function, cpu, nflows):
    trace_file = "trace_wg_decrypt" if function == "wg_packet_decrypt_worker" else "trace"
    trace_csv = pd.read_csv(f"CPU-{cpu}/nflow-{nflows}/trace/{function}/{trace_file}.csv") 
    return trace_csv
# toplevel = read_trace_csv("toplevel", 4, 2)

def read_toplevel_trace_data(traces, function, ncpus, nflows):
    time_len = traces["Timestamp"].shape[0]
    duration = traces["Timestamp"][time_len-1] - traces["Timestamp"][0]
    duration = duration * 10**9
    
    toplevel_traces = traces[(traces["event_type"] == "funcgraph_exit")]
    dataframe = traces.groupby(["Function", "Depth"]).sum().sort_values(by="Duration", ascending=False)
    dataframe = dataframe.reset_index(["Depth"], drop=True).drop(["Timestamp", "CPU"], axis=1)

    # Add the percentage column
    dataframe["Percentage"] = dataframe["Duration"].apply(lambda row: row/duration * 100)
    dataframe["Duration"] *= 10**-9
    
    dataframe = dataframe.T
    dataframe["Number of cores"] = ncpus
    dataframe["Number of flows"] = nflows
    
    return dataframe

def read_function_trace_data(traces, function, ncpus, nflows):
    time_len = traces["Timestamp"].shape[0]
    duration = traces["Timestamp"][time_len-1] - traces["Timestamp"][0]
    duration = duration * 10**9
    
    traces = traces[(traces["event_type"] == "funcgraph_exit")]
    dataframe = traces.groupby(["Function", "Depth"]).sum().sort_values(by="Duration", ascending=False)
    dataframe = dataframe.reset_index(["Depth"], drop=False).drop(["Timestamp", "CPU"], axis=1)

    duration_function = dataframe["Duration"][0]
    dataframe = dataframe[dataframe["Depth"] == 1]
    dataframe = dataframe.drop("Depth", axis=1)
    
    # Add the percentage column
    dataframe["Percentage"] = dataframe["Duration"].apply(lambda row: row/duration * 100)
    dataframe["Relative percentage"] = dataframe["Duration"].apply(lambda row: row/duration_function * 100)
    dataframe["Duration"] *= 10**-9
    
    dataframe = dataframe.T
    dataframe["Number of cores"] = ncpus
    dataframe["Number of flows"] = nflows
    
    return dataframe

def generate_one_csv(kwarg):
    core = kwarg[0]
    nflow = kwarg[1]
    print(f"Analyse with cores={core}, nflow={nflow}")
    sar_cpu, sar_memory, sar_network = read_sar_csv(core, nflow)
    data, data_std = serialize_sar(sar_cpu, ["%usr", "%sys", "%soft", "%idle"], core, nflow)
    data.to_csv(f"final_res/cpu_{core}_{nflow}.csv", index=False, encoding='utf-8')
    data, data_std = serialize_sar(sar_memory, ["kbmemused", "kbmemfree", "%memused", "%commit"], core, nflow)
    data.to_csv(f"final_res/memory_{core}_{nflow}.csv", index=False, encoding='utf-8')
    data = get_network_data(sar_network, "eno1", "wg", core, nflow)
    data.to_csv(f"final_res/network_{core}_{nflow}.csv", index=False, encoding='utf-8')
    #perf_data = read_perf_csv(core, nflow)
    #data, units = get_perf_data(perf_data, core, nflow)
    #data.to_csv(f"final_res/perf_{core}_{nflow}.csv", index=False, encoding='utf-8')
    #units.to_csv(f"final_res/perf_units.csv", encoding="utf-8")

    #if args.wireguard_activated:
    #    toplevel = read_trace_csv("toplevel", core, nflow)
    #    data = read_toplevel_trace_data(toplevel, "toplevel", core, nflow)
    #    data.to_csv(f"final_res/toplevel_{core}_{nflow}.csv", index=False, encoding='utf-8')

    #    wg_decrypt = read_trace_csv("wg_packet_decrypt_worker", core, nflow)
    #    data = read_function_trace_data(wg_decrypt, "wg_decrypt", core, nflow)
    #    data.to_csv(f"final_res/wg-decrypt_{core}_{nflow}.csv", index=False, encoding='utf-8')

def generate_all_csv(cores, nflows):
    index = product(cores, nflows)
    for core, nflow in index:
        generate_one_csv((core, nflow))

if __name__ == "__main__":
    p = Pool(args.concurrent)
    print(f"Launching analysis with {args.concurrent} processes.")
    tasks = list(product(cores, flows))
    p.map(generate_one_csv, tasks)
    p.close()
    p.join()

