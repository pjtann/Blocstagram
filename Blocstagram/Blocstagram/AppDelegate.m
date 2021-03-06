//
//  AppDelegate.m
//  Blocstagram
//
//  Created by PT on 1/11/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesTableViewController.h"
#import "LoginViewController.h"
#import "DataSource.h"





@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ImagesTableViewController alloc]init]];
    
    // create the data source so it can receive the access token notification
    [DataSource sharedInstance];
    
    // Our app should use this logic: at launch, show the login controller. Register for the LoginViewControllerDidGetAccessTokenNotification notification. When this notification posts, switch the root view controller from the login controller to the table controller
    // This will start the app with the login view controller, and switch to the images table controller once an access token is obtained.
    UINavigationController *navVC = [[UINavigationController alloc] init];
    
    if (![DataSource sharedInstance].accessToken) {
        
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [navVC setViewControllers:@[loginVC] animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note){
            ImagesTableViewController *imagesVC = [[ImagesTableViewController alloc] init];
            [navVC setViewControllers:@[imagesVC] animated:YES];
            
        }];
    }else{
        ImagesTableViewController *imagesVC = [[ImagesTableViewController alloc] init];
        [navVC setViewControllers:@[imagesVC] animated:YES];
    }
    
    self.window.rootViewController = navVC;
    
    
    
    // IS THIS STILL NEEDED? PJT
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
