//
//  NSDictionary+Profile.m
//  InterV
//
//  Created by HungLe on 11/10/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "NSDictionary+Profile.h"

@implementation NSDictionary (Profile)
- (NSDictionary *)results{
    return self[@"results"];
}
- (NSString *)address{
    return self[@"address"];
}
- (NSString*)avatar{
    return self[@"avatar"];
}
- (NSString*)cellphone{
    return self[@"cellphone"];
}
- (NSString*)city{
    return self[@"city"];
}
- (NSNumber*)executed{
    NSString *str = self[@"executed"];
    NSNumber *number = @([str boolValue]);
    return number;
}
- (NSString*)fname{
    return self[@"fname"];
}
- (NSString*)fullname{
    return self[@"fullname"];
}
- (NSString *)homephone{
    return self[@"homephone"];
}
- (NSString*)lname{
    return self[@"lname"];
}
- (NSString *)mname{
    return self[@"mname"];
}
- (NSString *)re_email{
    return self[@"re_email"];
}
- (NSString *)re_firstname{
    return self[@"re_firstname"];
}
- (NSString *)re_lastname{
    return self[@"re_lastname"];
}
- (NSString *)re_phone{
    return self[@"re_phone"];
}
- (NSString *)relationship{
    return self[@"relationship"];
}
- (NSString *)state{
    return self[@"state"];
}
- (NSString *)zipcode{
    return self[@"zipcode"];
}
@end
