//
//  Settings.m
//  InterV
//
//  Created by HungLe on 10/23/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "Settings.h"

typedef enum : int{
    BP = 2,
    SpO2 = 4,
    Heart_Rate = 9,
    Temperature = 3,
    SideEffect = 8,
    Survey = -1,
    Weight = 7,
    Self_Monitoring_of_Blood_Glucose = 422,
    FEV1 = 418,
    FEV1FVC = 419,
    FVC = 417,
} PatientCalendarTypeId;

@implementation Settings

// 7bc6eb
+ (UIColor *)setColorBG{
    UIColor *color = [UIColor colorWithRed:123.0/255.0 green:198.0/255.0 blue:235.0/255.0 alpha:1.0];
    return color;
}

//12465C
+ (UIColor *)setColorText{
    UIColor *color = [UIColor colorWithRed:18.0/255.0 green:72.0/255.0 blue:90.0/255.0 alpha:1.0];
    return color;
}

// ceeaf8
+ (UIColor *)setColorBGIMG{
    UIColor *color = [UIColor colorWithRed:206.0/255.0 green:234.0/255.0 blue:248.0/255.0 alpha:1.0];
    return color;
}

// aaaaaa
+ (UIColor *)setColorLine{
    UIColor *color = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
    return color;
}

+ (void)setBottomTF : (UITextField *)textField{
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, textField.frame.size.height - 1, textField.frame.size.width, 1);
    layer.backgroundColor = [[UIColor colorWithRed:205.0/255.0 green:204.0/255.0 blue:205.0/255.0 alpha:1.0] CGColor];
    textField.borderStyle = UITextBorderStyleNone;
    [textField.layer addSublayer:layer];
}

+ (void)setBottomLB : (UILabel *)label{
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, label.frame.size.height - 1, label.frame.size.width, 1);
    layer.backgroundColor = [[UIColor colorWithRed:0/255.0 green:175.0/255.0 blue:227.0/255.0 alpha:1.0] CGColor];
    [label.layer addSublayer:layer];
}

+ (NSString *)URLEncodeStringFromString:(NSString *)string
{
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str = (__bridge CFStringRef)string;
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}

+ (NSString *)getVersion{
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"InterveneRx, Version %@", version];
}

// generate secret key, encryption and decryption AES256

+ (NSString *)EnCryptionString : (id)parameter{
    NSString *key = SecretKey;
    key = [[StringEncryption alloc] sha256:key length:31];
    
    NSData *encryptData = [[StringEncryption alloc] encrypt:[parameter dataUsingEncoding:NSUTF8StringEncoding] key:key iv:IVKey];
    
    NSString *strEncrypt = [encryptData base64EncodedStringWithOptions:0];
    return strEncrypt;
}

+ (id)DeCryptionString : (NSString *)response{
    NSData *dataResponse = [[NSData alloc] initWithBase64EncodedString:response options:NSUTF8StringEncoding];
    NSString *strKey = [[StringEncryption alloc] sha256:SecretKey length:31];
    
//    NSError *error = nil;
    NSData *dataDecrypt = [[StringEncryption alloc] decrypt:dataResponse key:strKey iv:IVKey];
//    NSDictionary *dt = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:&error];
    NSString *decryptedText = [[NSString alloc] initWithData:dataDecrypt encoding:NSUTF8StringEncoding];
    return decryptedText;
}

+ (NSString *)EnCryptionDictionary : (id)parameter{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:parameter options:0 error:&err];
    
    NSString *strTemp = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *key = SecretKey;
    key = [[StringEncryption alloc] sha256:key length:31];
    
    NSData *encryptData = [[StringEncryption alloc] encrypt:[strTemp dataUsingEncoding:NSUTF8StringEncoding] key:key iv:IVKey];
    
    NSString *strEncrypt = [encryptData base64EncodedStringWithOptions:0];
    return strEncrypt;
}

+ (id)DeCryptionData : (NSString *)response{
    NSData *dataResponse = [[NSData alloc] initWithBase64EncodedString:response options:NSUTF8StringEncoding];
    NSString *strKey = [[StringEncryption alloc] sha256:SecretKey length:31];
    
    NSError *error = nil;
    NSData *dataDecrypt = [[StringEncryption alloc] decrypt:dataResponse key:strKey iv:IVKey];
    NSDictionary *dt = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:&error];
    return dt;
}

//+ (id)DeCryptionString : (NSString *)response{
//    NSData *dataResponse = [[NSData alloc] initWithBase64EncodedString:response options:NSUTF8StringEncoding];
//    NSString *strKey = [[StringEncryption alloc] sha256:SecretKey length:31];
//    
//    NSError *error = nil;
//    NSData *dataDecrypt = [[StringEncryption alloc] decrypt:dataResponse key:strKey iv:IVKey];
////    NSDictionary *dt = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:&error];
//    return dataDecrypt;
//}

    // check pattern BP, SPO2
+ (NSDictionary *)checkPattern : (int)PatientCalendarTypeId : (NSString *)pattern{
    NSRange typeRange;
    NSDictionary *dict = [[NSDictionary alloc] init];
    if (PatientCalendarTypeId == BP) {
        typeRange = [pattern rangeOfString:kPatternBP
                                           options:NSRegularExpressionSearch];
        if (typeRange.location != NSNotFound) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"status", @"", @"message", nil];
            return dict;
        }
        dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"status", @"Incorrect format, please enter format as X/Y,Z for Systolic/Diastolic,Pulse where each is 2 or 3 digit value.", @"message", nil];
        return dict;
    }else if (PatientCalendarTypeId == SpO2){
        typeRange = [pattern rangeOfString:kPatternSPO2
                                   options:NSRegularExpressionSearch];
        if (typeRange.location != NSNotFound) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"status", @"", @"message", nil];
            return dict;
        }
        dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"status", @"Incorrect format, please enter format as X,Y for SpO2,Pulse where each is 2 or 3 digit value.", @"message", nil];
        return dict;
    }else if (PatientCalendarTypeId == Temperature){
        /// temperature
        typeRange = [pattern rangeOfString:kPatternTemperature
                                   options:NSRegularExpressionSearch];
        if (typeRange.location != NSNotFound) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"status", @"", @"message", nil];
            return dict;
        }else{
            typeRange = [pattern rangeOfString:kPatternTemperature1
                                       options:NSRegularExpressionSearch];
            if (typeRange.location != NSNotFound){
                dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"status", @"", @"message", nil];
                return dict;
            }
        }
        dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"status", @"Incorrect format, please enter format as X for Temperature as 2 to 4 digit value.", @"message", nil];
        return dict;
    }else if (PatientCalendarTypeId == Heart_Rate){
        // heart rate
        typeRange = [pattern rangeOfString:kPatternHR
                                   options:NSRegularExpressionSearch];
        if (typeRange.location != NSNotFound) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"status", @"", @"message", nil];
            return dict;
        }
        dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"status", @"Incorrect format, please enter format as X for Pulse as 2 or 3 digit value.", @"message", nil];
        return dict;
    }
    return dict;
}

+ (BOOL)expressionResult : (NSString *)string : (NSString *)pattern{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];

    if (numberOfMatches == 0)
        return NO;
    return YES;
}

@end
