//
//  MAPBottomView.h
//  BaiDuMap
//
//  Created by YuXiang on 2017/6/20.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAPBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                currentLocStr:(NSString *)locStr
                  destination:(NSString *)destination;

- (void)updateLocationLbl:(NSString *)locationStr;
- (void)updateDestinationLbl:(NSString *)destinationStr;

@end
