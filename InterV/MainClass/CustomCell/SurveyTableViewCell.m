//
//  SurveyTableViewCell.m
//  InterV
//
//  Created by HungLe on 12/27/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "SurveyTableViewCell.h"

@implementation SurveyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.lblQuestionName.frame.size.height = self.frame.size.height;
}

- (void)layoutSubviews{
//    self.contentView
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(
                                        indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints,
                                        self.contentView.frame.size.height
                                        );
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
