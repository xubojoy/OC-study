//
//  SchoolIntroDuceController.h
//  DrAssistant
//
//  Created by hi on 15/9/4.
//  Copyright (c) 2015年 Doctor. All rights reserved.
//

#import "BaseViewController.h"
#import "MyClubEntity.h"
@interface SchoolIntroDuceController : BaseViewController
@property (nonatomic, strong) MyClubEntity *ClubInfo;
@property (weak, nonatomic) IBOutlet UIImageView *clubBigImage;
@end
