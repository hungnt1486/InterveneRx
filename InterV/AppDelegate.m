//
//  AppDelegate.m
//  InterV
//
//  Created by HungLe on 10/4/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate (){
    BOOL checkStateApp;
}

@end

@implementation AppDelegate

static AppDelegate *_instance;

@synthesize tabbar = _tabbar;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _instance = self;
    checkStateApp = false;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLinkServerAPI] != NULL) {
        _strLinkServer = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLinkServerAPI];
    }else{
        _strLinkServer = @"https://sd.intervenerx.com";
    }
//    [NSString stringWithFormat:@"%@/api/", _strLinkServer];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserDefaultLogin];
    if (dict.count > 0) {
        [self LoginSuccess];
    }else{
        [self CheckLogin];
    }
    
    // local notification
//    UIUserNotificationSettings *notificationSetting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge| UIUserNotificationTypeSound categories:nil];
//    [application registerUserNotificationSettings:notificationSetting];
//
//
//
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionSound + UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong");
        }
    }];
//    self.center = [UNUserNotificationCenter currentNotificationCenter];
//    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
//    [self.center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Something went wrong");
//        }
//    }];
    // end local notification
    
    return YES;
}

- (void)CheckLogin{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.window.rootViewController = login;
    [self.window makeKeyAndVisible];
}

- (void)LoginSuccess{
    tabbar = [[UITabBarController alloc] init];
    tabbar.delegate = self;
    
    [UITabBar appearance].tintColor = [Settings setColorBG];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [Settings setColorText]} forState:UIControlStateSelected];
    
    calendar = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
    calendar.title = @"Calendar";
    calendar.tabBarItem.tag = 1;
    calendar.tabBarItem.image = [UIImage imageNamed:@"IconCalendar"];
    UINavigationController *nav_cal = [[UINavigationController alloc] initWithRootViewController:calendar];
//    nav_cal.navigationBar.backgroundColor = [Settings setColorBG];
//    nav_cal.navigationBar.tintColor = [Settings setColorBG];
//    nav_cal.navigationBar.barTintColor = [Settings setColorBG];
//    nav_cal.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
//    bioMetrics = [[BioMetricsViewController alloc] initWithNibName:@"BioMetricsViewController" bundle:nil];
//    bioMetrics.title = @"BioMetrics";
//    bioMetrics.tabBarItem.tag = 2;
//    UINavigationController *nav_bio = [[UINavigationController alloc] initWithRootViewController:bioMetrics];
    
    profile = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    profile.title = @"Profile";
    profile.tabBarItem.tag = 3;
    profile.tabBarItem.image = [UIImage imageNamed:@"IconProfile"];
    UINavigationController *nav_profile = [[UINavigationController alloc] initWithRootViewController:profile];
    
    tabbar.viewControllers = [NSArray arrayWithObjects:nav_cal, nav_profile, nil];
    
    self.window.rootViewController = tabbar;
    
    [self.window makeKeyAndVisible];
    [self hideProgressHub];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    NSLog(@"gegw = %@", ((UITabBarController*)self.window.rootViewController).selectedViewController);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin] != NULL) {
        UINavigationController *nav = ((UITabBarController*)self.window.rootViewController).selectedViewController;
        if ([nav.visibleViewController isKindOfClass:[CalendarViewController class]]) {
            if (checkStateApp) {
                NSLog(@"abc");
                checkStateApp = false;
                [[CalendarViewController ShareInstance] showAlertWhenAppActive];
            }
            
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma Local Notification


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    NSLog(@"notificationSettings = %@", notificationSettings);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSLog(@"notification = %@", notification.alertBody);
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        if ([CalendarViewController ShareInstance] != NULL) {
            NSLog(@"notification = %@", notification);
            // show banner top
            [[CalendarViewController ShareInstance] showAlertBannerTop:notification.alertBody view:tabbar.view];
            // end show banner top
            NSDate *date = [NSDate date];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
            NSString *strFireDate = [format stringFromDate:notification.fireDate];
            NSString *strDateNow = [format stringFromDate:date];
            if ([strDateNow isEqualToString:strFireDate]) {
                [[CalendarViewController ShareInstance] showAlertWhenAppActive];
            }
        }
    }
    else{
        // app in background
        checkStateApp = true;
        
        // background task manager
//        self.localNotificationTracking.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
//        [self.localNotificationTracking.bgTask beginNewBackgroundTask];
//        self.localNotificationTracking.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
//                                       selector:@selector(test)
//                                       userInfo:nil
//                                        repeats:NO];
    }
}

- (void)test{
    NSLog(@"background task manager success");
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    NSLog(@"completionHandler");
    completionHandler();
}

- (void)showProgressHub{
    [MBProgressHUD showHUDAddedTo:self.window animated:YES];
}

- (void)hideProgressHub{
    [MBProgressHUD hideHUDForView:self.window animated:YES];
}

+(AppDelegate *)shareInstance{
    return _instance;
}
+ (NSString *)getLinkServer{
    return [[AppDelegate shareInstance] strLinkServer];
}

@end
