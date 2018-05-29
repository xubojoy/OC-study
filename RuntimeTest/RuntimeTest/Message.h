//
//  Message.h
//  RuntimeTest
//
//  Created by xubojoy on 2018/3/19.
//  Copyright © 2018年 xubojoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
@property int localID;
@property(retain) NSString *content;
@property(retain) NSDate *createTime;
@property(retain) NSDate *modifiedTime;
@property(assign) int unused; //You can only define the properties you need
@end
