//
//  AppDelegate.m
//  BBZVideoEngine
//
//  Created by HaiboZhu on 2020/4/8.
//  Copyright © 2020 HaiboZhu. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeTableViewController.h"
#import "BBZErrorMonitor.h"

@interface AppDelegate ()
@property (atomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[BBZErrorMonitor shareInstance] addErrorBlock:^(NSError *error) {
        NSSet *ignoredErrors = [NSSet setWithObjects:@(401), @(4097),@(2),@(260), nil];
        if (error && ![ignoredErrors containsObject:@(error.code)]) {
            BBZINFO(@"BBZErrorMonitor %@", [NSString stringWithFormat:@"%@:%ld",error.domain,(long)error.code]);
        }
    }];
    
    HomeTableViewController *homeVc = [[HomeTableViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homeVc];
    rootViewController = nav;
    //    [nav setNavigationBarHidden:YES];
    [nav.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setShadowImage:[UIImage new]];
    nav.navigationBar.translucent = NO;
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    //    rootViewController = [[SimpleVideoFilterViewController alloc] initWithNibName:@"SimpleVideoFilterViewController" bundle:nil];
    //    rootViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.window addSubview:rootViewController.view];
    
    [self.window setRootViewController:rootViewController];
    
    [self.window makeKeyAndVisible];
    

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
//    usleep(1000);
    NSLog(@"applicationWillResignActive 1");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground 1");
//    usleep(9000);
    NSLog(@"applicationDidEnterBackground 2");
    if (self.backgroundTask != UIBackgroundTaskInvalid) {    // 双击home之后，关闭程序，仍然会进到这个程序里来，这时候结束就可以了
        NSLog(@"backgroundTask != UIBackgroundTaskInvalid return");
        return;
    }
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{

        
        NSLog(@"***********程序将被系统挂起***********");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
        NSLog(@"***********程序将被系统挂起 结束***********");
    }];
    
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        NSLog(@"**********后台任务开启失败!");
        return;
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
//    usleep(1000);
    NSLog(@"applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
//    usleep(1000);
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
