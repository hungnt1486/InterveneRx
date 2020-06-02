//
//  Settings.h
//  InterV
//
//  Created by HungLe on 10/23/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (UIColor *)setColorBG;
+ (UIColor *)setColorText;
+ (UIColor *)setColorBGIMG;
+ (UIColor *)setColorLine;
+ (void)setBottomTF : (UITextField *)textField;
+ (void)setBottomLB : (UILabel *)label;
+ (NSString *)URLEncodeStringFromString:(NSString *)string;
+ (NSString *)getVersion;

// generate secret key, encryption and decryption AES256
+ (NSString *)EnCryptionString : (id)parameter;
+ (id)DeCryptionString : (NSString *)response;
+ (NSString *)EnCryptionDictionary : (NSDictionary *)parameter;
+ (id)DeCryptionData : (NSString *)response;

// check pattern BP, SPO2
+ (NSDictionary *)checkPattern : (int)PatientCalendarTypeId : (NSString *)pattern;

// check expression for BP, SPO2, Temperature
+ (BOOL)expressionResult : (NSString *)string : (NSString *)pattern;

@end
