//
//  SlideMenuAndMulitViewAppDelegate.m
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import "AppDelegate.h"
#import "BackgroundRunner.h"
#import "iMonLog.h"
#import "ViewController.h"

@interface AppDelegate ()

@end


@implementation AppDelegate {
    NSString *_logFilePath;
    iMonLog *_imonLog;
    ViewController *_viewController;
}

static NSDateFormatter *formatter = nil;
+ (void)initialize
{
    formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[UIDevice currentDevice] isMultitaskingSupported])
    {
        [[BackgroundRunner shared] run];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[BackgroundRunner shared] stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //[self saveContext];
}


@end
