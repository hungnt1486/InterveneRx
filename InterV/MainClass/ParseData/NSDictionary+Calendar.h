//
//  NSDictionary+Calendar.h
//  InterV
//
//  Created by HungLe on 10/28/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Calendar)
- (NSArray *)results;
- (NSString *)DisplayName;
- (NSNumber*)Id;
- (NSNumber*)InProgress;
- (NSNumber*)PatientCalendarTypeId;
- (NSNumber*)Status;
- (NSNumber*)StatusDetail;
- (NSNumber*)StatusDetailDone;
- (NSString *)Time;
- (NSNumber*)TimeLogId;
- (NSString *)Value;
- (NSNumber *)Earlytimehour;
- (NSString *)isBaseline;
- (NSString *)timeValid;
- (NSNumber*)InputType;
- (NSNumber*)Max;
@end
