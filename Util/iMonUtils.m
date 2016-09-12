//
//  AppDelegate.m
//  iMon
//
//  Created by naver on 2014. 11. 3..
//  Copyright (c) 2014년 ansi. All rights reserved.
//

#import "iMonUtils.h"


BOOL firstIter = true;

void getTraffic (void)
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    NSString *name;
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            // NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                // NSLog (@"interface name : %@", name);
                // lo0, pdp_ip0, pdp_ip1, pdp_ip2, pdp_ip3, ap1, en0, en1, awdl0
                
                if ([name hasPrefix:@"en0"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    
                    currentWiFi.rx = networkStatisc->ifi_ibytes / 1024;
                    currentWiFi.tx = networkStatisc->ifi_obytes / 1024;
                    
                    currentWiFi.rxError = networkStatisc->ifi_ierrors / 1024;
                    currentWiFi.txError = networkStatisc->ifi_oerrors / 1024;
                    
                    currentWiFi.rxPacket = networkStatisc->ifi_ipackets;
                    currentWiFi.txPacket = networkStatisc->ifi_opackets;
                    
                    //NSLog(@"WiFi RX : %d / TX : %d\n", currentWiFiRx, currentWiFiTx);
                }
                
                if ([name hasPrefix:@"pdp_ip0"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    
                    currentCell.rx = networkStatisc->ifi_ibytes / 1024;
                    currentCell.tx = networkStatisc->ifi_obytes / 1024;
                    
                    currentCell.rxError = networkStatisc->ifi_ierrors / 1024;
                    currentCell.txError = networkStatisc->ifi_oerrors / 1024;
                    
                    currentCell.rxPacket = networkStatisc->ifi_ipackets;
                    currentCell.txPacket = networkStatisc->ifi_opackets;
                     
                    //NSLog(@"Cell RX : %d / TX : %d\n", currentCellRx, currentCellTX);
                }
                
                if ([name hasPrefix:@"lo0"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    
                    currentLocal.rx = networkStatisc->ifi_ibytes / 1024;
                    currentLocal.tx = networkStatisc->ifi_obytes / 1024;
                    
                    currentLocal.rxError = networkStatisc->ifi_ierrors / 1024;
                    currentLocal.txError = networkStatisc->ifi_oerrors / 1024;
                    
                    currentLocal.rxPacket = networkStatisc->ifi_ipackets;
                    currentLocal.txPacket = networkStatisc->ifi_opackets;
                    
                    //NSLog(@"Local RX : %d / TX : %d\n", currentLocal.rx, currentLocal.tx);
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
        
        if (firstIter == true) {
            
            currentWiFi.rxOld = 0;
            currentWiFi.txOld = 0;
            currentWiFi.rxFirst = currentWiFi.rx;
            currentWiFi.txFirst = currentWiFi.tx;
            
            currentWiFi.rxPacketOld = 0;
            currentWiFi.txPacketOld = 0;
            currentWiFi.rxPacketFirst = currentWiFi.rxPacket;
            currentWiFi.txPacketFirst = currentWiFi.txPacket;
            
            currentCell.rxOld = 0;
            currentCell.txOld= 0;
            currentCell.rxFirst = currentCell.rx;
            currentCell.txFirst = currentCell.tx;
            
            currentCell.rxPacketOld = 0;
            currentCell.txPacketOld = 0;
            currentCell.rxPacketFirst = currentCell.rxPacket;
            currentCell.txPacketFirst = currentCell.txPacket;
            
            currentLocal.rxOld = 0;
            currentLocal.txOld = 0;
            currentLocal.rxFirst = currentLocal.rx;
            currentLocal.txFirst = currentLocal.tx;
            
            currentLocal.rxPacketOld = 0;
            currentLocal.txPacketOld = 0;
            currentLocal.rxPacketFirst = currentLocal.rxPacket;
            currentLocal.txPacketFirst = currentLocal.txPacket;

            firstIter = false;
        }
    }
}

void getCPU (void)
{
    natural_t numCPUsU = 0U;
    
    //kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    
    int mib[2U] = { CTL_HW, HW_NCPU };
    
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    
    if(status)
        numCPUs = 2;
    
    CPUUsageLock = [[NSLock alloc] init];

    [CPUUsageLock lock];
    
    for(unsigned i = 0U; i < numCPUs; ++i) {
        static float inUse, total;
        if(prevCpuInfo) {
            inUse = ((cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                     + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo [(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]));
            total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
        } else {
            inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
        }
        
        if (i == 0) {
            currentCPU.core0 = (inUse/total)*100;
            //NSLog(@"Core: %u Usage: %.2f",i,currentCPU.core0);
        }
        
        else if (i == 1) {
            currentCPU.core1 = (inUse/total)*100;
            //NSLog(@"Core: %u Usage: %.2f",i,currentCPU.core1);
        }
    }
    
    [CPUUsageLock unlock];
    
    if(prevCpuInfo) {
        size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
        
        mig_deallocate((vm_address_t)prevCpuInfo, prevCpuInfoSize);
        //vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
    }
    
    prevCpuInfo = cpuInfo;
    numPrevCpuInfo = numCpuInfo;
    cpuInfo = NULL;
    numCpuInfo = 0U;
}


void getUsedMemory(){
    size_t length;
    int mib[6];
    
    int pagesize;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        perror("getting page size");
    }
    
    // iPhone5S page size = 16384 -> displayed Total Memory 4GB / physical = 1G
    pagesize = 4096;
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        printf("Failed to get VM statistics.");
    }
    
    currentMemory.used = (vmstat.wire_count * pagesize / 1024 / 1024) + (vmstat.active_count * pagesize / 1024 / 1024) + (vmstat.inactive_count * pagesize / 1024 / 1024);
}


void getMemory()
{
    size_t length;
    int mib[6];
    int result;
    
    int pagesize;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        perror("getting page size");
    }

    // iPhone5S page size = 16384 -> displayed Total Memory 4GB / physical = 1G
    pagesize = 4096;
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        printf("Failed to get VM statistics.");
    }
    
    currentMemory.wired = vmstat.wire_count * pagesize / 1024 / 1024;
    currentMemory.active = vmstat.active_count * pagesize / 1024 / 1024;
    currentMemory.inactive = vmstat.inactive_count * pagesize / 1024 / 1024;
    currentMemory.free = vmstat.free_count * pagesize / 1024 / 1024;
    currentMemory.zerofill = vmstat.zero_fill_count * pagesize / 1024 / 1024;
//    currentMemory.used = (currentMemory.physical / 1024) - currentMemory.free;
    currentMemory.used = currentMemory.wired + currentMemory.active + currentMemory.inactive;
    currentMemory.total = currentMemory.used + currentMemory.free;
    
    
    // CTL_HW identifiers
    // #define	HW_MODEL        2		/* string: specific machine model */
    // #define	HW_NCPU         3		/* int: number of cpus */
    // #define	HW_PHYSMEM      5		/* int: total memory */
    // #define	HW_USERMEM      6		/* int: non-kernel memory */
    // #define	HW_PAGESIZE     7		/* int: software page size */
    // #define  HW_AVAILCPU     25		/* int: number of available CPUs */
    
    mib[0] = CTL_HW;
    mib[1] = HW_PHYSMEM;
    length = sizeof(result);
    
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
    {
        perror("getting physical memory");
    }
    currentMemory.physical = result / 1024;
    
    mib[0] = CTL_HW;
    mib[1] = HW_USERMEM;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
    {
        perror("getting user memory");
    }
    currentMemory.user = result / 1024;
    
    mib[0] = CTL_HW;
    mib[1] = HW_NCPU;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
    {
        perror("getting user memory");
    }
    //printf ("Number of CPUs : %d\n", result);
    
    mib[0] = CTL_HW;
    mib[1] = HW_AVAILCPU;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
    {
        perror("getting user memory");
    }
    //printf ("Number of available CPUs : %d\n", result);
}


void printProcessorInfo()
{
    size_t length;
    int mib[6];
    int result;
    
    printf("Processor Info\n");
    printf("--------------\n");
    
    mib[0] = CTL_HW;
    mib[1] = HW_CPU_FREQ;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
    {
        perror("getting cpu frequency");
    }
    printf("CPU Frequency = %d hz\n", result);
    
    mib[0] = CTL_HW;
    mib[1] = HW_BUS_FREQ;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0)
    {
        perror("getting bus frequency");
    }
    printf("Bus Frequency = %d hz\n", result);
    printf("\n");
}


int printProcessInfo() {
    int mib[5];
    struct kinfo_proc *procs = NULL, *newprocs;
    int i, st, nprocs;
    size_t miblen, size;
    
    /* Set up sysctl MIB */
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;
    mib[3] = 0;
    miblen = 4;
    
    /* Get initial sizing */
    st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    /* Repeat until we get them all ... */
    do {
        /* Room to grow */
        size += size / 10;
        newprocs = realloc(procs, size);
        if (!newprocs) {
            if (procs) {
                free(procs);
            }
            perror("Error: realloc failed.");
            return (0);
        }
        procs = newprocs;
        st = sysctl(mib, miblen, procs, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st != 0) {
        perror("Error: sysctl(KERN_PROC) failed.");
        return (0);
    }
    
    /* Do we match the kernel? */
    assert(size % sizeof(struct kinfo_proc) == 0);
    
    nprocs = size / sizeof(struct kinfo_proc);
    
    if (!nprocs) {
        perror("Error: printProcessInfo.");
        return(0);
    }
    
    printf("  PID\tName\n");
    printf("-----\t--------------\n");
    for (i = nprocs-1; i >=0;  i--) {
        printf("%5d\t%s\n",(int)procs[i].kp_proc.p_pid, procs[i].kp_proc.p_comm);

    }
    free(procs);
    return (0);
}

/*
 int printBatteryInfo()
 {
 CFTypeRef blob = IOPSCopyPowerSourcesInfo();
 CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
 
 CFDictionaryRef pSource = NULL;
 const void *psValue;
 
 int numOfSources = CFArrayGetCount(sources);
 if (numOfSources == 0) {
 perror("Error getting battery info");
 return 1;
 }
 
 printf("Battery Info\n");
 printf("------------\n");
 
 for (int i = 0 ; i < numOfSources ; i++)
 {
 pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
 if (!pSource) {
 perror("Error getting battery info");
 return 2;
 }
 psValue = (CFStringRef)CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));
 
 int curCapacity = 0;
 int maxCapacity = 0;
 int percent;
 
 psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
 CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
 
 psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
 CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
 
 percent = (int)((double)curCapacity/(double)maxCapacity * 100);
 
 printf ("powerSource %d of %d: percent: %d/%d = %d%%\n", i+1, CFArrayGetCount(sources), curCapacity, maxCapacity, percent);
 printf("\n");
 
 }
 }
 */

/*
 void getMemory (void)
 {
 mach_port_t host_port;
 mach_msg_type_number_t host_size;
 vm_size_t pagesize;
 
 host_port = mach_host_self();
 host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
 host_page_size(host_port, &pagesize);
 
 NSLog (@"page size : %lu\n", pagesize);
 
 vm_statistics_data_t vm_stat;
 
 if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
 NSLog(@"Failed to fetch vm statistics");
 
 currentMemory.physical = NSRealMemoryAvailable() / 1024 / 1024;
 currentMemory.active = vm_stat.active_count * pagesize / 1024 / 1024;
 currentMemory.inactive = vm_stat.inactive_count * pagesize / 1024 / 1024;
 currentMemory.wired = vm_stat.wire_count * pagesize / 1024 / 1024;
 currentMemory.free = vm_stat.free_count * pagesize / 1024 / 1024;
 
 currentMemory.used = currentMemory.active + currentMemory.inactive;
 currentMemory.total = currentMemory.used + currentMemory.free;
 }
 */

/*
 void report_memory(void) {
 static unsigned last_resident_size=0;
 static unsigned greatest = 0;
 static unsigned last_greatest = 0;
 
 struct task_basic_info info;
 mach_msg_type_number_t size = sizeof(info);
 kern_return_t kerr = host_info(mach_task_self(),
 TASK_BASIC_INFO,
 (task_info_t)&info,
 &size);
 if( kerr == KERN_SUCCESS ) {
 int diff = (int)info.resident_size - (int)last_resident_size;
 unsigned latest = info.resident_size;
 if( latest > greatest   )   greatest = latest;  // track greatest mem usage
 int greatest_diff = greatest - last_greatest;
 int latest_greatest_diff = latest - greatest;
 NSLog(@"Mem: %10lu (%10d) : %10d :   greatest: %10u (%d)", info.resident_size, diff,
 latest_greatest_diff,
 greatest, greatest_diff  );
 
 } else {
 NSLog(@"Error with task_info(): %d", mach_error_string(kerr));
 }
 last_resident_size = info.resident_size;
 last_greatest = greatest;
 }
 */



