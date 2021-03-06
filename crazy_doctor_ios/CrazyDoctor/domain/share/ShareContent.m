//
//  ShareContent.m
//
//  Created by wangwanggy820 on 14-8-8.
//  Copyright (c) 2014年 mlzj. All rights reserved.
//

#import "ShareContent.h"

@implementation ShareContent

-(id)initWithTitle:(NSString *)title content:(NSString *)content wxSessionContent:(NSString *)wxSessionContent sinaWeiBoContent:(NSString *)sinaWeiBoContent url:(NSString *)url image:(UIImage *)image imageUrl:(NSString *)imageUrl imageArray:(NSArray *)imageArray{

    self = [super init];
    if (self) {
        self.title = title;
        self.content = content;
        self.wxSessionContent = wxSessionContent;
        self.sinaWeiBoContent = sinaWeiBoContent;
        self.url = url;
        self.image = image;
        self.imageUrl = imageUrl;
        self.imageArray = imageArray;
    }
    return self;
}

@end
