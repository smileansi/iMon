//
//  AppDelegate.m
//  iMon
//
//  Created by naver on 2014. 11. 3..
//  Copyright (c) 2014년 ansi. All rights reserved.
//

#import "iMonLog.h"

@implementation iMonLog {
    NSString *_logFilePath;
    //int _previousBatteryCapacity;
    
}

- (id)initWithLogFileName:(NSString *)logFileName {
    self = [super init];
    if (self) {
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = documentPaths[0];
        _logFilePath = [[documentsDir stringByAppendingPathComponent:logFileName] stringByAppendingPathExtension:@"csv"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:_logFilePath]) {
            NSArray *headers = @[
            @"Time",
            @"Core #0(%)",
            @"Core #1(%)",
            @"Total Memory(MB)",
            @"Wired Memory(MB)",
            @"Used Memory(MB)",
            @"Active Memory(MB)",
            @"Inactive Memory(MB)",
            @"Free Memory(MB)",
            @"User Memory(MB)",
            @"WiFi RX(KB)",
            @"WiFi TX(KB)",
            @"Cellular RX(KB)",
            @"Cellular TX(KB)",
            @"Local RX(KB)",
            @"Local TX(KB)",
            @""
            ];
            NSData *headersData = [[NSString stringWithFormat:@"%@\n", [headers componentsJoinedByString:@","]] dataUsingEncoding:NSUTF8StringEncoding];
            [headersData writeToFile:_logFilePath atomically:YES];
            
        }
    }

    return self;
}

- (NSString *) getDate
{
    NSDateFormatter *dform = [[NSDateFormatter alloc]init];
    dform.dateFormat = @"yyyy.MM.dd hh:mm:ss.SSS";
    NSString *date = [dform stringFromDate:[NSDate new]];
    
    return date;
}

- (id)appendLogEntry {
    
    getCPU();
    getMemory();
    getTraffic();
    
    //printMemoryInfo();
    //printProcessorInfo();
    //printBatteryInfo();
    //printProcessInfo();
    
    NSArray *logEntryComponents = @[
                                    //[NSDate new]
                                    [self getDate],
    
                                    // CPU Core 0 & 1
                                    [NSNumber numberWithFloat:currentCPU.core0],
                                    [NSNumber numberWithFloat:currentCPU.core1],
    
                                    // Memory
                                    [NSNumber numberWithLong:currentMemory.total],
                                    [NSNumber numberWithLong:currentMemory.wired],
                                    [NSNumber numberWithLong:currentMemory.used],
                                    [NSNumber numberWithLong:currentMemory.active],
                                    [NSNumber numberWithLong:currentMemory.inactive],
                                    [NSNumber numberWithLong:currentMemory.free],
                                    [NSNumber numberWithLong:currentMemory.user / 1024],
    
    
                                    // WiFi Traffics
                                    [NSNumber numberWithInt:currentWiFi.rx - currentWiFi.rxOld],
                                    [NSNumber numberWithInt:currentWiFi.tx - currentWiFi.txOld],
    
                                    // Cellular Traffics
                                    [NSNumber numberWithInt:currentCell.rx - currentCell.rxOld],
                                    [NSNumber numberWithInt:currentCell.tx - currentCell.txOld],
                                    
                                    // Local Traffics
                                    [NSNumber numberWithInt:currentLocal.rx - currentLocal.rxOld],
                                    [NSNumber numberWithInt:currentLocal.tx - currentLocal.txOld],
                                    ];
    
    currentWiFi.rxOld = currentWiFi.rx;
    currentWiFi.txOld = currentWiFi.tx;
    
    currentCell.rxOld = currentCell.rx;
    currentCell.txOld = currentCell.tx;
    
    currentLocal.rxOld = currentLocal.rx;
    currentLocal.txOld = currentLocal.tx;
    
    NSString *logEntry = [logEntryComponents componentsJoinedByString:@","];

    NSLog(@"%@", logEntry);

    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:_logFilePath];
    [handle seekToEndOfFile];
    NSString *logEntryWithNewLine = [NSString stringWithFormat:@"%@\n", logEntry];
    [handle writeData:[logEntryWithNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    [handle synchronizeFile];
    [handle closeFile];
    
    return logEntry;
}



@end