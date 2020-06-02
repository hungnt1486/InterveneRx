//
//  CalendarTableViewCell.h
//  InterV
//
//  Created by HungLe on 10/24/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnInputResult;
@property (weak, nonatomic) IBOutlet UIButton *btnTakeMeasurement;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UIView *vLine;
@property (weak, nonatomic) IBOutlet UIImageView *imgMissed;

- (void)checkingStatus : (NSNumber*)InProgress Time : (NSString *)Time;

@end
