# WireGuard Experiment Configuration Documentation

This YAML configuration file defines parameters for WireGuard performance testing experiments. The file uses Ansible's variable structure and controls various aspects of network performance testing, hardware configuration, and software settings.

## Core Configuration

```yaml
all:
  vars:
    ncore_set: "36"             # Number of CPU cores to use
    nflow_set: [100]            # Number of flows to test
    unit_time_s: 60             # Duration of each test in seconds
    mps: 22300                  # Maximum packets per second
```

## Batch Processing Parameters

```yaml
    # Batch params:
    with_batch_sizes: False     # Enable/disable batch size testing
    batch_sizes: [2, 4, 8, 16]  # Batch sizes to test when enabled
    concurrency_levels: [4, 8, 16, 32]  # Concurrency levels to test
    custom_kernel_on: 'client'  # Apply custom kernel on 'client' side
```

## Multi-Queue Parameters

```yaml
    # Multi queue param:
    with_nr_rings: False        # Enable/disable testing multiple network rings
    nr_rings: [2, 4, 8, 18]     # Number of network interface rings to test when enabled
```

## Performance Testing Tools Selection

```yaml
    # Testing type choice
    test_iperf3: true           # Enable iperf3 testing
    test_netperf: false         # Enable netperf testing
    test_hey: false             # Enable hey HTTP benchmarking tool
    test_deathstar: false       # Enable deathstar testing framework
```

## Network Traffic Configuration

```yaml
    # Network Configuration
    download: false             # Test download traffic (from server to client)
    bidirectional: false        # Test bidirectional traffic
```

## Netperf Specific Arguments

```yaml
    # NETPERF args 
    netperf_testname: "TCP_STREAM"  # Netperf test type (TCP_STREAM sends from client to server)
                                    # TCP_MAERTS sends from server to client
    latency_test: "TCP_RR"          # Latency test type (TCP_RR or UDP_RR for UDP)
    latency_req_res_size: "1500,1500"  # Request and response sizes in bytes (default "1,1")
```

## Iperf3 Specific Arguments

```yaml
    # IPERF3 args
    iperf_udp: False            # Use UDP instead of TCP for iperf3 tests
    queue_length: 1024          # Socket buffer queue length
    bandwidth: 300Mbits         # Target bandwidth for testing
    packet_size: 128K           # Packet size (MAX = 1048576 bytes for TCP, 1460 for UDP)
```

## IRQ and RSS (Receive Side Scaling) Configuration

```yaml
    # IRQBalance/RSS config
    irqbalanced: true           # Enable IRQ balance daemon
    test_latency: false         # Enable latency testing
    all_on_core_0: False        # Pin all interrupts to CPU core 0
    deactivate_rss: false       # Disable Receive Side Scaling
```

## NAPI, Kernel Thread, and SMT Configuration

```yaml
    # NAPI/KTHREAD/WQ/SMT config
    pinned_napi: False          # Pin NAPI (Network API) processing to specific cores
    threaded: 0                 # Use threaded IRQs (0 = disabled)
    hyperthreaded: false        # Use hyperthreading
    smt: "off"                  # Simultaneous Multi-Threading: "on" or "off"
```

## SockPerf Arguments

```yaml
    # SOCKPERF args
    PPS: 12500                  # Packets per second per client
    SOCKPERF_TRAFFIC: tcp       # Traffic type: "tcp" or "udp"
    MSG_LEN: 1300               # Message length in bytes
```

## RPS (Receive Packet Steering) and RFS (Receive Flow Steering) Configuration

```yaml
    # RPS/RFS config
    enable_rps: false           # Enable Receive Packet Steering
    enable_rfs: false           # Enable Receive Flow Steering
```

## WireGuard Implementation Selection

```yaml
    # Wireguard type choice
    custom_kernel: false               # Use custom kernel implementation
    version_kernel: kernel-6.1         # Kernel version when custom_kernel is true
    custom_go: false                   # Use custom Go implementation
    version_go: partial_encrypt        # Go version variant: "partial_encrypt" or "no_encrypt"
    wg_userspace: false                # Use userspace WireGuard implementation
    wireguard_go_tailscale: false      # Use Tailscale's Go implementation
    boringtun: false                   # Use BoringTun (Rust implementation by Cloudflare)
    wireguard_rs: false                # Use wireguard-rs (Rust implementation)
```

## Scheduler Policy Configuration

```yaml
    # Sched policy
    apply_sched_policy: false          # Apply custom scheduler policy
    sched_policy: "-o"                 # Scheduler policy:
                                       #  -o: default
                                       #  -b: batch
                                       #  -f: fifo
                                       #  -r: round robin
                                       #  -d: deadline
    sched_priority: 0                  # Scheduler priority (0 for default/batch, 1+ for fifo/round robin)
    runs: 1                            # Number of test runs
    wait_server: 0                     # Wait time before server start (seconds)
    wait_client: 0                     # Wait time before client start (seconds)
```

## Usage Notes

1. This configuration is designed to be used with the WireGuard experiment framework that uses Ansible for deployment and testing.

2. To run different experiments:
   - For batch size testing: Set `with_batch_sizes: True`
   - For multi-queue testing: Set `with_nr_rings: True`
   - For different WireGuard implementations: Enable one of the WireGuard type options

3. Testing tool selection:
   - At least one of the testing tools (`test_iperf3`, `test_netperf`, etc.) should be enabled
   - Each tool measures different aspects of network performance

4. When testing with custom kernels or implementations, ensure the corresponding artifacts are available in the `wireguard-artefacts/` directory.

5. The scheduler policy settings allow for testing how different Linux process scheduling algorithms affect WireGuard performance.