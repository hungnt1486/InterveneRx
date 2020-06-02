//
//  Define.h
//  InterV
//
//  Created by HungLe on 10/5/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#ifndef Define_h
#define Define_h

#define kAppDelegate  (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define docDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kUserDefaultLogin @"login"
#define kReminderSurvey @"ReminderSurvey"
#define kDictInputTextSurvey @"DictInputTextSurvey"
#define kArraySurvey  @"ArraySurvey"
#define kEventIDSurvey @"EventIDSurvey"
#define kUserDefaultLinkServerAPI @"linkserver"
#define kArrayIDRegisterPushNotifications @"ArrayIDRegisterPushNotifications"

//NSTimeInterval const kMaxTimeOut = 30.0f;
#define kMaxTimeOut 30.0f

#define kIP5H   568
#define kIP6H   667
#define kIP6PH  736
#define kIPadM  1024

// 123/34/54
#define kPatternBP @"[0-9]{2,3}[/]{1}[0-9]{2,3}[,]{1}[0-9]{2,3}+"
#define kExpressionBP @"^([0-9]{1,3}+)?([\\/]([0-9]{1,3})?)?([\\,]([0-9]{1,3})?)?$"
// 53/33
#define kPatternSPO2 @"[0-9]{2,3}[,]{1}[0-9]{2,3}+"
#define kExpressionSPO2 @"^([0-9]{1,3}+)?([\\,]([0-9]{1,3})?)?$"

// temperature
#define kPatternTemperature @"[0-9]{2,3}[.][0-9]{1}+"
#define kPatternTemperature1 @"[0-9]{2,3}"
#define kExpressionTemperature @"^([0-9]{1,3}+)?([\\.]([0-9]{1})?)?$"

// Heart rate
#define kPatternHR @"[0-9]{2,3}"
#define kExpressionHR @"^([0-9]{1,3}+)?$"

#define SAFE_RELEASE_ARRAY(p)               { if (p) { [(p) removeAllObjects]; (p) = nil;  } }

// define key IV & Secret

#define IVKey @"WOjfrpQdkfdpWJD"
#define SecretKey @"SODJWewtsgdWEREECjcdid"

// define link api

//#define kLink @"http://dev.intervrx.com/api/"
//#define kLinkAvatar @"http://dev.intervrx.com"
#define kLink [NSString stringWithFormat:@"%@/api/", kLinkAvatar]//@"https://qa.intervenerx.com/api/"
#define kLinkAvatar [[AppDelegate shareInstance] strLinkServer]//@"https://qa.intervenerx.com"
//#define kLink @"https://sandbox.intervenerx.com/api/"
//#define kLinkAvatar @"https://sandbox.intervenerx.com"
// api state
#define kState @"state"
//api login
#define kAccount @"accounts"
// api calendar
#define kCalendar @"calendar"
// api profile
#define kProfile  @"profile"
// api change password
#define kChangePassword @"security"
// api upload avatar
#define kUploadAvatar   @"patientinformation"
#define kSurvey @"survey"
#define kCreateAccount @"account"
#endif /* Define_h */
