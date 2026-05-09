# Indoor 6G Factory Simulation — MATLAB

Phase 2 of the Indoor 6G Resource Allocation Simulation: an indoor factory scenario with autonomous robots, multi-BS scheduling, and 3GPP InH-Office channel modeling.

---

## Quick start

1. Open MATLAB and `cd` into the `Indoor6G_MATLAB/` folder.
2. Run `main_Indoor6G.m`.
3. KPI table prints in the Command Window; four figures open automatically.

> The main script calls `addpath(genpath(projectRoot))` so all subfolders are on the path automatically.

---

## Project structure

```
Indoor6G_MATLAB/
│
├── main_Indoor6G.m            ← Entry point — runs the full pipeline
│
├── config/
│   └── getConfig.m            ← All simulation parameters (geometry, channel, traffic, scheduler)
│
├── mobility/
│   ├── generateLanes.m        ← Computes equally-spaced lane center positions
│   ├── initRobots.m           ← Initialises robot state (position, speed, direction, lane IDs)
│   └── updateRobotPositions.m ← Advances all robots by one time step with lane switching
│
├── channel/
│   ├── computeDistance.m      ← 2D distance tensor [T, B, U] between robots and base stations
│   ├── isLOS.m               ← LOS probability (3GPP TR 38.901 InH-Office)
│   ├── computePathLoss.m     ← Path loss model (LOS / NLOS with shadowing)
│   └── computeSINR.m         ← Received power, thermal noise, SNR, interference-free rate
│
├── traffic/
│   ├── generateTraffic.m     ← Bernoulli packet arrivals (all robots get eMBB + URLLC)
│   ├── initQueues.m          ← Creates empty per-robot packet queues
│   ├── enqueuePackets.m      ← Adds newly arrived packets to queues
│   └── dropExpiredPackets.m  ← Removes packets past their deadline
│
├── scheduler/
│   ├── rrScheduler.m         ← Round-robin scheduler (0-based pointer)
│   ├── pfScheduler.m         ← Proportional-fair scheduler
│   ├── deadlineScheduler.m   ← Earliest-deadline-first with rate tie-break
│   ├── servePackets.m        ← Drains URLLC then eMBB packets up to bit budget
│   ├── queueBacklog.m        ← Total pending bits per user
│   └── earliestDeadline.m    ← Slots remaining until most urgent packet expires
│
├── metrics/
│   ├── runSimulation.m       ← Full time-domain simulation loop for one scheduler
│   └── summarizeResults.m    ← Computes KPI summary (throughput, success rate, delay)
│
└── plots/
    ├── plotFactory.m          ← Factory layout with robot trajectories
    ├── plotDistances.m        ← Distance evolution (BS1 → robots)
    └── plotResults.m          ← Backlog timeline + KPI dashboard (3 bar charts)
```

---

## Simulation pipeline

The main script executes these steps in order:

1. **Configuration** — `getConfig()` loads all parameters into a single `CFG` struct.
2. **Mobility trace** — Robots are placed on a 2×2 lane grid and move for 1200 time slots (60 s at 50 ms per slot).
3. **Channel trace** — 2D/3D distances, LOS state, path loss with log-normal shadowing, and interference-free rates are computed for every (time slot, BS, robot) triple.
4. **Traffic generation** — Bernoulli arrivals produce eMBB and URLLC packets for all robots.
5. **Scheduling** — Three schedulers (RR, PF, Deadline) are run independently on the same trace.
6. **KPI summary** — Throughput, packet success rate, and mean/p95 delay are computed per scheduler.
7. **Plots** — Four figures visualise the factory layout, distances, backlog, and KPI comparison.

---

## Schedulers

| Scheduler | File | Strategy |
|-----------|------|----------|
| Round-robin | `rrScheduler.m` | Cycles through users with backlog in fixed order |
| Proportional-fair | `pfScheduler.m` | Maximises instantaneous rate / average rate ratio |
| Deadline-aware | `deadlineScheduler.m` | Picks user with earliest expiring packet; breaks ties by rate |

All schedulers share the same interface: they receive a backlog-flag vector and channel info, and return a `selected` vector mapping each BS to its scheduled user.

---

## Key parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Simulation time | 60 s | Total simulated duration |
| Slot duration | 50 ms | Scheduler time step |
| Factory size | 30 × 16 m | Width × height |
| Robots | 3 | All receive both eMBB and URLLC |
| Base stations | 2 | Corners: (0.5, 0.5) and (29.5, 15.5) |
| Carrier frequency | 3.5 GHz | Sub-6 GHz band |
| Bandwidth | 2 MHz | System bandwidth |
| TX power | 3 dBm | Per-link transmit power |
| eMBB packets | 180–260 kbits | 30% arrival prob, 1.5 s deadline |
| URLLC packets | 1.2–2.2 kbits | 25% arrival prob, 100 ms deadline |

---

## Output

**Command Window** — KPI table with columns: scheduler, offered/served Mbps, load ratio, eMBB/URLLC success rates, mean and p95 delay.

**Figure 1** — Factory layout with robot trajectories and BS positions.

**Figure 2** — Distance from BS1 to each robot over time.

**Figure 3** — Total queue backlog (Mbits) over time for all three schedulers.

**Figure 4** — KPI dashboard: served throughput, packet success rate, and mean delay bar charts.

---

## Reference implementation

The Python reference (`Indoor_6G_Resource_Allocation_Simulation.py`) uses NumPy with `default_rng(2026)` (PCG64). This MATLAB version follows identical algorithmic logic. KPI distributions converge statistically; individual sample paths differ due to the RNG algorithm difference (MATLAB uses Mersenne Twister).

---

## Requirements

- MATLAB R2020b or later (uses `arguments` blocks and modern table functions).
- No additional toolboxes required.
