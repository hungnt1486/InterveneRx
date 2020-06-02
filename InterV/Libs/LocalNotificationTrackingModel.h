//
//  LocalNotificationTrackingModel.h
//  InterveneRx
//
//  Created by ITPM on 3/29/18.
//  Copyright © 2018 HungLe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"

@interface LocalNotificationTrackingModel : NSObject

@property (nonatomic) BackgroundTaskManager * bgTask;
@property (nonatomic) NSTimer *timer;

+(id)ShareLocalNotificationTrackingModel;

@end
