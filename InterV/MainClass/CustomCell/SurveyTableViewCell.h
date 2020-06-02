//
//  SurveyTableViewCell.h
//  InterV
//
//  Created by HungLe on 12/27/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SurveyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestionName;

@end
