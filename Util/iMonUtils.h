//
//  AppDelegate.m
//  iMon
//
//  Created by naver on 2014. 11. 3..
//  Copyright (c) 2014년 ansi. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <mach/host_info.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>
#include <mach/processor_info.h>

#include <sys/sysctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <netdb.h>

#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>

#if TARGET_IPHONE_SIMULATOR
#error iMon only works on physical iOS devices
#endif

processor_info_array_t cpuInfo, prevCpuInfo;
mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;

unsigned numCPUs;

NSLock *CPUUsageLock;

struct cpuData {
    
    float core0;
    float core1;
    
} currentCPU;

struct memoryData {
    
    double physical;
    double user;
    double total;
    double wired;
    double used;
    double free;
    double active;
    double inactive;
    double resident;
    double virtualSize;
    double pageIn;
    double pageOut;
    double zerofill;

    
} currentMemory;

struct wifiData {
    
    u_int32_t rx;
    u_int32_t tx;
    u_int32_t rxOld;
    u_int32_t txOld;
    u_int32_t rxFirst;
    u_int32_t txFirst;
    u_int32_t rxError;
    u_int32_t rxPacket;
    u_int32_t txError;
    u_int32_t txPacket;
    u_int32_t rxPacketOld;
    u_int32_t txPacketOld;
    u_int32_t rxPacketFirst;
    u_int32_t txPacketFirst;
    
} currentWiFi;

struct cellData {
    
    u_int32_t rx;
    u_int32_t tx;
    u_int32_t rxOld;
    u_int32_t txOld;
    u_int32_t rxFirst;
    u_int32_t txFirst;
    u_int32_t rxError;
    u_int32_t rxPacket;
    u_int32_t txError;
    u_int32_t txPacket;
    u_int32_t rxPacketOld;
    u_int32_t txPacketOld;
    u_int32_t rxPacketFirst;
    u_int32_t txPacketFirst;
    
} currentCell;

struct localData {
    
    u_int32_t rx;
    u_int32_t tx;
    u_int32_t rxOld;
    u_int32_t txOld;
    u_int32_t rxFirst;
    u_int32_t txFirst;
    u_int32_t rxError;
    u_int32_t rxPacket;
    u_int32_t txError;
    u_int32_t txPacket;
    u_int32_t rxPacketOld;
    u_int32_t txPacketOld;
    u_int32_t rxPacketFirst;
    u_int32_t txPacketFirst;
    
} currentLocal;


void getCPU (void);
void getMemory (void);
void getTraffic (void);

void getUsedMemory (void);
void printMemoryInfo(void);

