//
//  NSDictionary+Calendar.m
//  InterV
//
//  Created by HungLe on 10/28/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "NSDictionary+Calendar.h"

@implementation NSDictionary (Calendar)
- (NSArray *)results{
    return self[@"results"];
}
- (NSString *)DisplayName{
    return self[@"DisplayName"];
}
- (NSNumber*)Id{
    NSString *str = self[@"Id"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSNumber*)InProgress{
    NSString *str = self[@"InProgress"];
    NSNumber *number = @([str boolValue]);
    return number;
}
- (NSNumber *)Earlytimehour{
    NSString *str = self[@"Earlytimehour"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSNumber*)PatientCalendarTypeId{
    NSString *str = self[@"PatientCalendarTypeId"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSNumber*)Status{
    NSString *str = self[@"Status"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSNumber*)StatusDetail{
    NSString *str = self[@"StatusDetail"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSNumber*)StatusDetailDone{
    NSString *str = self[@"StatusDetailDone"];
    NSNumber *number = @([str boolValue]);
    return number;
}
- (NSString *)Time{
    return self[@"Time"];
}
- (NSNumber*)TimeLogId{
    NSString *str = self[@"TimeLogId"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSString *)Value{
    return self[@"Value"];
}
- (NSString *)isBaseline{
    return self[@"isBaseline"];
//    NSNumber *number = @([str boolValue]);
//    return number;
}

- (NSString *)timeValid{
    return self[@"timevalid"];
}

// moi them
- (NSNumber*)InputType{
    NSString *str = self[@"InputType"];
    NSNumber *number = @([str intValue]);
    return number;
}
- (NSNumber*)Max{
    NSString *str = self[@"Max"];
    NSNumber *number = @([str intValue]);
    return number;
}
// end moi them
@end
