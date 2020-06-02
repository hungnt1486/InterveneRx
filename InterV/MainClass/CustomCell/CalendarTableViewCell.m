//
//  CalendarTableViewCell.m
//  InterV
//
//  Created by HungLe on 10/24/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "CalendarTableViewCell.h"

@implementation CalendarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    self.lblTimer.textColor = [Settings setColorText];
    self.lblTitle.textColor = [Settings setColorText];
    
    [_btnInputResult setTitleColor:[Settings setColorBG] forState:UIControlStateNormal];
    [_btnInputResult.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    
    _btnTakeMeasurement.layer.cornerRadius = 5.0;
    _btnTakeMeasurement.backgroundColor = [Settings setColorBG];
    [_btnTakeMeasurement setTitleColor:[Settings setColorText] forState:UIControlStateNormal];
    
    _btnDone.layer.cornerRadius = 5.0;
    _btnDone.backgroundColor = [Settings setColorBG];
    [_btnDone setTitleColor:[Settings setColorText] forState:UIControlStateNormal];
    
    _btnNext.layer.cornerRadius = 5.0;
    _btnNext.backgroundColor = [Settings setColorBG];
    [_btnNext setTitleColor:[Settings setColorText] forState:UIControlStateNormal];
    
    _vLine.backgroundColor = [Settings setColorLine];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)checkingStatus : (NSNumber*)InProgress Time : (NSString *)Time{
    NSLog(@"InProgress = %@", InProgress);
    NSLog(@"timer = %@", Time);
    NSArray *arrTime = [Time componentsSeparatedByString:@":"];
    NSLog(@"arrTime = %@", arrTime);
    NSInteger hours = [[arrTime objectAtIndex:0] integerValue];
    NSInteger minutes = [[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0] integerValue];
    NSNumber *numberSecond = [NSNumber numberWithInteger:hours*60*60 + minutes*60];
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm"];
    NSArray *arrCurrentTime = [[format stringFromDate:date] componentsSeparatedByString:@":"];
    NSInteger hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];
    NSInteger minutesCurrent = [[arrCurrentTime objectAtIndex:1] integerValue];
    NSNumber *numberSecondsCurrent = [NSNumber numberWithInteger:hoursCurrent*60*60 + minutesCurrent*60];
    if (numberSecondsCurrent <= numberSecond) {
        _btnInputResult.hidden = NO;
    }
    else{
        _btnInputResult.hidden = YES;
    }
}

@end
