Folder structure
Indoor6G_MATLAB
│
├── main.m
├── config/
│   └── getConfig.m
│
├── mobility/
│   ├── generateLanes.m
│   ├── initRobots.m
│   └── updateRobotPositions.m
│
├── channel/
│   ├── computeDistance.m
│   ├── isLOS.m
│   ├── computePathLoss.m
│   └── computeSINR.m
│
├── traffic/
│   ├── generateTraffic.m
│   ├── initQueues.m
│   ├── enqueuePackets.m
│   └── dropExpiredPackets.m
│
├── scheduler/
│   ├── pfScheduler.m
│   ├── allocateResources.m
│   └── updateAverageRate.m
│
├── metrics/
│   ├── initMetrics.m
│   ├── updateMetrics.m
│   └── summarizeResults.m
│
└── plots/
    ├── plotFactory.m
    ├── plotDistances.m
    └── plotResults.m
