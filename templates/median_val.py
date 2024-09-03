#! /usr/bin/python3

import pandas as pd
import argparse


parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', required=True)
parser.add_argument('-o', '--output', default='tmp')
parser.add_argument('-c', '--cpu', type=int, required=False)
parser.add_argument('-n', '--flow', type=int, required=False)
parser.add_argument('-f', '--fields', required=False, default=None)


args = parser.parse_args()
df = pd.read_csv(args.input)
cpu = int(args.cpu)
flow = int(args.flow)
if args.fields is not None:
    df = df.groupby(args.fields).median().reset_index()
    df['cpu'] = cpu
    df['flow'] = flow
else: 
    # Only working for cpuload. TODO: make this generic
    val = df['runq-sz'].median()
    df = pd.DataFrame([val, cpu, flow]).T

df.to_csv(f'{args.output}_{args.cpu}_{args.flow}.csv', index=False, header=False)
