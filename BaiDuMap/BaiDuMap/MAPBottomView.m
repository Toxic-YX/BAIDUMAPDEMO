//
//  MAPBottomView.m
//  BaiDuMap
//
//  Created by YuXiang on 2017/6/20.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//

#import "MAPBottomView.h"

@interface MAPBottomView ()

@property (nonatomic, strong) UILabel *currentLocTitle;
@property (nonatomic, strong) UILabel *currentLocContent;

@property (nonatomic, strong) UILabel *destinationTitle;
@property (nonatomic, strong) UILabel *destinationContent;

@property (nonatomic, copy) NSString *locStr;
@property (nonatomic, copy) NSString *destinationStr;

@end
@implementation MAPBottomView

- (instancetype)initWithFrame:(CGRect)frame currentLocStr:(NSString *)locStr destination:(NSString *)destination {
    if (self = [super initWithFrame:frame]) {
        self.locStr = locStr;
        self.destinationStr = destination;
        self.backgroundColor = [UIColor grayColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _currentLocTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, kLableWidth, kHeight)];
    _currentLocTitle.text = self.locStr;
    _currentLocTitle.font = [UIFont systemFontOfSize:14];
    _currentLocTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_currentLocTitle];
    
    _currentLocContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_currentLocTitle.frame),0, kLableWidth, kHeight)];
    _currentLocContent.text = @"无";
    _currentLocContent.font = [UIFont systemFontOfSize:14];
    _currentLocContent.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_currentLocContent];
    
    UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_currentLocContent.frame), 0, 50, kHeight)];
    arrowImg.image = [UIImage imageNamed:@"arrow"];
    [self addSubview:arrowImg];
    
    _destinationTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowImg.frame), 0, 50, kHeight)];
    _destinationTitle.text = self.destinationStr;
    _destinationTitle.font = [UIFont systemFontOfSize:14];
    _destinationTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_destinationTitle];
    
    _destinationContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_destinationTitle.frame),0, kLableWidth, kHeight)];
    _destinationContent.text = @"无";
    _destinationContent.font = [UIFont systemFontOfSize:14];
    _destinationContent.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_destinationContent];
}

- (void)updateLocationLbl:(NSString *)locationStr {
    _currentLocContent.text = locationStr;
}

- (void)updateDestinationLbl:(NSString *)destinationStr {
    _destinationContent.text = destinationStr;
}
@end
