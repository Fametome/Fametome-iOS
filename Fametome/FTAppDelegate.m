//
//  FTAppDelegate.m
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTAppDelegate.h"

@implementation FTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    
    //sleep(2); // for custom Launch image
    
    // Parse
    [Parse setApplicationId:@"onturXZAM4c3z4z7xXRJA93OtGBALa6Olen3n1xb"
                  clientKey:@"F5U4m1BebeZA1D17naEf7iQR9VKcamaQrwkGos1m"];
    
    // Register for Push Notification
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFImageView class];
    
    // Apparence
    [self.window.layer setCornerRadius:2];
    [self.window.layer setMasksToBounds:YES];
    
    // iosSideMenu
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    FTLeftMenuViewController *leftMenu = (FTLeftMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"FTLeftMenuViewController"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;

    return YES;
}

#pragma mark - Push notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    //[currentInstallation deviceType];
    // Associate the device with a user
    if([PFUser currentUser])
        currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

#pragma mark - Original Methods
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}

@end
