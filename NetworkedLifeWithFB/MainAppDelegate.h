//
//  MainAppDelegate.h
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
