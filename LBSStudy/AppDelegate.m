//
//  AppDelegate.m
//  LBSStudy
//
//  Created by Dio Brand on 2022/7/18.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    MainViewController *main = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:main];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
