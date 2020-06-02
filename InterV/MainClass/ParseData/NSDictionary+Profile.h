//
//  NSDictionary+Profile.h
//  InterV
//
//  Created by HungLe on 11/10/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Profile)
- (NSDictionary *)results;
- (NSString *)address;
- (NSString*)avatar;
- (NSString*)cellphone;
- (NSString*)city;
- (NSNumber*)executed;
- (NSString*)fname;
- (NSString*)fullname;
- (NSString *)homephone;
- (NSString*)lname;
- (NSString *)mname;
- (NSString *)re_email;
- (NSString *)re_firstname;
- (NSString *)re_lastname;
- (NSString *)re_phone;
- (NSString *)relationship;
- (NSString *)state;
- (NSString *)zipcode;
@end
