//
//  SlideMenuAndMulitViewAppDelegate.h
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSTimeInterval _backgroundRunningTimeInterval;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isForeground;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

/*
 - (NSURL *)applicationDocumentsDirectory;
 - (void)saveContext;
 */

@end