//
//  LocalNotificationTrackingModel.m
//  InterveneRx
//
//  Created by ITPM on 3/29/18.
//  Copyright © 2018 HungLe. All rights reserved.
//

#import "LocalNotificationTrackingModel.h"

@implementation LocalNotificationTrackingModel

+(id)ShareLocalNotificationTrackingModel{
    static id ShareLocalNotificationTrackingModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ShareLocalNotificationTrackingModel = [[self alloc] init];
    });
    return ShareLocalNotificationTrackingModel;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end
