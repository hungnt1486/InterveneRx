//
//  AppDelegate.h
//  InterV
//
//  Created by HungLe on 10/4/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "LocalNotificationTrackingModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>{
    UITabBarController *tabbar;
    CalendarViewController *calendar;
    BioMetricsViewController *bioMetrics;
    ProfileViewController *profile;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic)UITabBarController *tabbar;
@property (nonatomic, strong) NSString *strLinkServer;

// background task manager
@property(nonatomic) LocalNotificationTrackingModel *localNotificationTracking;

+(AppDelegate *)shareInstance;
- (void)CheckLogin;
- (void)LoginSuccess;
- (void)showProgressHub;
- (void)hideProgressHub;
+ (NSString *)getLinkServer;

@end

