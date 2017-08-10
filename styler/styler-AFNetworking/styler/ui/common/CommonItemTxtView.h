//
//  CommonItemTxtView.h
//  styler
//
//  Created by wangwanggy820 on 14-4-8.
//  Copyright (c) 2014年 mlzj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonItemTxtView : UIView

@property (nonatomic, strong) NSArray *commonItemTxtArray;

-(id) initWithFrame:(CGRect)frame commonItemTxtArray:(NSArray *)commonItemTxtArray font:(UIFont *)font;

+(float) judgeHeight:(NSArray *)commonItemTxtArray font:(UIFont *)font;

@end
