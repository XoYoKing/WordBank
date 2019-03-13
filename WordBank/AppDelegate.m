//
//  AppDelegate.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "BmobSDK/Bmob.h"
#import "ProfileViewController.h"
#import "DictViewController.h"
#import "TransViewController.h"
#import "VideoTableViewController.h"
#import <KSGuaidViewManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册Bomob
    [Bmob registerWithAppKey:@"6ff29515adaaad3f81e0f0cd39757ed9"];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#pragma 主页
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    HomeViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IDENTIFIER"];
    vc.title = @"首页";
    vc.tabBarItem.image = [UIImage imageNamed:@"首页"];
    UINavigationController *navForHome = [[UINavigationController alloc] initWithRootViewController:vc];
        
#pragma 翻译
    UIStoryboard *storyboardOfDictView = [UIStoryboard storyboardWithName:@"DictView" bundle:[NSBundle mainBundle]];
    DictViewController *dictVC = [storyboardOfDictView instantiateViewControllerWithIdentifier:@"DictVC"];
    dictVC.title = @"翻译";
    dictVC.tabBarItem.image = [UIImage imageNamed:@"翻译"];
    UINavigationController *navForDict = [[UINavigationController alloc] initWithRootViewController:dictVC];
    
#pragma 词典
    UIStoryboard *storyboardOfTransView = [UIStoryboard storyboardWithName:@"Trans" bundle:[NSBundle mainBundle]];
    TransViewController *transVC = [storyboardOfTransView instantiateViewControllerWithIdentifier:@"TransVC"];
    transVC.title = @"词典";
    transVC.tabBarItem.image = [UIImage imageNamed:@"词典"];
    UINavigationController *navForTrans = [[UINavigationController alloc] initWithRootViewController:transVC];
#pragma 视频
    VideoTableViewController *VideoVC = [[VideoTableViewController alloc] init];
    VideoVC.title = @"视频教程";
    VideoVC.tabBarItem.image = [UIImage imageNamed:@"视频"];
    UINavigationController *navForVideo = [[UINavigationController alloc] initWithRootViewController:VideoVC];
#pragma 我的中心
    UIStoryboard *storyboardOfProfile = [UIStoryboard storyboardWithName:@"Profile" bundle:[NSBundle mainBundle]];
    ProfileViewController *profileVC = [storyboardOfProfile instantiateViewControllerWithIdentifier:@"profileVC"];
    profileVC.title = @"我的中心";
    profileVC.tabBarItem.image = [UIImage imageNamed:@"我的中心"];
    UINavigationController *navForProfile = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.viewControllers = @[navForHome,navForDict,navForTrans,navForVideo,navForProfile];
    self.window.rootViewController = tabBar;
    
    [self.window makeKeyWindow];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
