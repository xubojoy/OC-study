//
//  PhysiotherapyDetailConfirmController.m
//  CrazyDoctor
//
//  Created by xubojoy on 16/5/9.
//  Copyright © 2016年 xubojoy. All rights reserved.
//

#import "PhysiotherapyDetailConfirmController.h"
#import "OrderStore.h"
#import "MHActionSheet.h"
#import "NewProjectOrder.h"
#import "MyOrdersController.h"
#import "CrazyDoctorTabbar.h"
#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "SelectPayTypeController.h"
#import "SelectCouponController.h"
#import "UserStore.h"
@interface PhysiotherapyDetailConfirmController ()

@end

@implementation PhysiotherapyDetailConfirmController

- (instancetype)initWithProjectId:(int)projectId{
    self = [super init];
    if (self) {
        self.projectId = projectId;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedPaymentNoti:) name:@"传递支付方式" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCouponNoti:) name:@"选择优惠券" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [ColorUtils colorWithHexString:common_bg_color];
    self.view.autoresizesSubviews = NO;
    self.projectArray = [NSMutableArray new];
    self.organizationArray = [NSMutableArray new];
    self.tmpRedCouponId = 0;
    self.isClick = NO;
    [self initHeadView];
    [self loadData];
    [self loadUserAccountData];
    [self initTableView];
    [self initBottomBtnView];
}

//初始化自定义导航
-(void)initHeadView{
    self.headerView = [[HeaderView alloc] initWithTitle:@"预约理疗" navigationController:self.navigationController];
    [self.view addSubview:self.headerView];
}

- (void)loadUserAccountData{
    [UserStore getUserAccount:^(UserAccount *userAccount, NSError *err) {
        NSLog(@">>>>>>>userAccount>>>>>>%@",userAccount);
        if (userAccount != nil) {
            self.userAccount = userAccount;
        }
    }];
}

- (void)loadData{
    [OrderStore getProjectById:^(NSDictionary *projectDict, NSError *err) {
        if (projectDict != nil) {
            self.project = [[Project alloc] initWithDictionary:projectDict error:nil];
            NSLog(@">>>>>数组数据>>>>>>%@------%@",self.project,self.project);
        }else{
            ExceptionMsg *exception = [[err userInfo] objectForKey:@"ExceptionMsg"];
            [self.view makeToast:exception.message duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        }
        [self.tableView reloadData];
    } projectId:self.projectId];
}

- (void)selectedPaymentNoti:(NSNotification *)notifi{
    self.selectedPayTypeStr = (NSString *)notifi.object;
    NSLog(@">>>>>传递支付方式>>>>>>%@",self.selectedPayTypeStr);
    self.payTypeLabel.text = self.selectedPayTypeStr;
    self.payTypeTitleLabel.text = @"支付方式";
    self.payTypeTitleLabel.textColor = [UIColor blackColor];
    self.tmpRedCouponId = 0;
    self.youhuiquanLabel.text = [NSString stringWithFormat:@"-¥0"];
    self.discountPriceLabel.text = [NSString stringWithFormat:@"¥0"];
    self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",(self.project.specialPrice)];

}

- (void)selectedCouponNoti:(NSNotification *)notifi{
    self.redEnvelope = (RedEnvelope *)notifi.object;
    NSLog(@">>>>>传递优惠券>>>>>>%@",self.redEnvelope);
    if ([self.redEnvelope.type isEqualToString:@"meetSubtract"]) {
        if (self.project.specialPrice >= self.redEnvelope.meetAmount) {
            self.youhuiquanLabel.text = [NSString stringWithFormat:@"-¥%d",self.redEnvelope.amount];
            self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",(self.project.specialPrice-self.redEnvelope.amount)];
            self.discountPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.redEnvelope.amount];
            
            self.tmpRedCouponId = self.redEnvelope.id;
        }else{
            self.youhuiquanLabel.text = [NSString stringWithFormat:@"-¥0"];
            self.discountPriceLabel.text = [NSString stringWithFormat:@"¥0"];
            self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",(self.project.specialPrice)];
            self.tmpRedCouponId = 0;
        }
    }else{
        self.youhuiquanLabel.text = [NSString stringWithFormat:@"-¥%d",self.redEnvelope.amount];
        if (self.project.specialPrice >= self.redEnvelope.amount) {
            self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",(self.project.specialPrice-self.redEnvelope.amount)];
            self.discountPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.redEnvelope.amount];
            
        }else{
            self.priceLabel.text = [NSString stringWithFormat:@"¥0"];
            self.discountPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",self.project.specialPrice];
        }
        self.tmpRedCouponId = self.redEnvelope.id;
    }
    self.youhuiTitleLabel.text = @"优惠券";
    self.youhuiTitleLabel.textColor = [UIColor blackColor];
}

//初始化tableview
-(void)initTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.frame.size.height+splite_line_height, screen_width,screen_height-self.headerView.frame.size.height-60) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [ColorUtils colorWithHexString:common_bg_color];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - tableViewDelegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 8;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else if (section == 7){
        return 3;
    }
    else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [UITableViewCell new];
            self.physiotherapyDetailTopView = [[PhysiotherapyDetailTopView alloc] initWithFrame:CGRectMake(general_padding, general_padding, screen_width-20, 195)];
            [self.physiotherapyDetailTopView renderPhysiotherapyDetailTopViewWithProject:self.project];
            [cell.contentView addSubview:self.physiotherapyDetailTopView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [ColorUtils colorWithHexString:common_bg_color];
            return cell;
        }else if (indexPath.row == 1){
            static NSString *jiuzhenrenxingmingID = @"jiuzhenrenxingming";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:jiuzhenrenxingmingID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiuzhenrenxingmingID];
                
                self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 130, 50)];
                self.nameLabel.text = @"请输入就诊人姓名";
                self.nameLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                self.nameLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
                [cell.contentView addSubview:self.nameLabel];
                
                self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(general_margin, 0, screen_width-30, 50)];
                
                self.nameTextField.delegate = self;
                self.nameTextField.backgroundColor = [UIColor clearColor];
                self.nameTextField.textAlignment = NSTextAlignmentRight;
                [self.nameTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
                [cell.contentView addSubview:self.nameTextField];
                
                UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
                downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
                [cell.contentView addSubview:downLine];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;

        }else if (indexPath.row == 2){
            static NSString *jiuzhenrendtelID = @"jiuzhenrendtel";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:jiuzhenrendtelID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiuzhenrendtelID];
                
                self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 130, 50)];
                self.phoneLabel.text = @"请输入就诊人电话";
                self.phoneLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                self.phoneLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
                [cell.contentView addSubview:self.phoneLabel];
                
                
                self.phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(general_margin, 0, screen_width-30, 50)];
                
                self.phoneTextField.delegate = self;
                self.phoneTextField.textAlignment = NSTextAlignmentRight;
                self.phoneTextField.backgroundColor = [UIColor clearColor];
                self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
                [self.phoneTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
                [cell.contentView addSubview:self.phoneTextField];
                UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
                downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
                [cell.contentView addSubview:downLine];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;

        }else{
            static NSString *jiuzhenrendageID = @"jiuzhenrendage";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:jiuzhenrendageID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiuzhenrendageID];
                
                self.ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 130, 50)];
                self.ageLabel.text = @"请输入就诊人年龄";
                self.ageLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                self.ageLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
                [cell.contentView addSubview:self.ageLabel];
                
                self.ageTextField = [[UITextField alloc] initWithFrame:CGRectMake(general_margin, 0, screen_width-30, 50)];
                self.ageTextField.delegate = self;
                self.ageTextField.textAlignment = NSTextAlignmentRight;
                self.ageTextField.keyboardType = UIKeyboardTypeDecimalPad;
                self.ageTextField.backgroundColor = [UIColor clearColor];
                [self.ageTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
                [cell.contentView addSubview:self.ageTextField];
                UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
                downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
                [cell.contentView addSubview:downLine];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
    }
    else if (indexPath.section == 1){
        static NSString *jiuzhenrenxingbieID = @"jiuzhenrenxingbie";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:jiuzhenrenxingbieID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiuzhenrenxingbieID];
            
            self.sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 50)];
            self.sexLabel.text = @"就诊人性别";
            self.sexLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.sexLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
            [cell.contentView addSubview:self.sexLabel];
            
            self.sexTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 50)];
            self.sexTitleLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.sexTitleLabel.backgroundColor = [UIColor whiteColor];
            self.sexTitleLabel.textColor = [UIColor blackColor];
            self.sexTitleLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:self.sexTitleLabel];
            
            UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-30, general_margin, general_space, general_space)];
            arrowImgView.image = [UIImage imageNamed:@"icon_arrow"];
            [cell.contentView addSubview:arrowImgView];
            
            UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
            downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
            [cell.contentView addSubview:downLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;

    }else if (indexPath.section == 2){
        static NSString *jiuzhenriqiID = @"jiuzhenriqi";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:jiuzhenriqiID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jiuzhenriqiID];
            
            self.dateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 50)];
            self.dateTitleLabel.text = @"就诊日期";
            self.dateTitleLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.dateTitleLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
            [cell.contentView addSubview:self.dateTitleLabel];
            
            self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 50)];
            self.dateLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.dateLabel.backgroundColor = [UIColor whiteColor];
            self.dateLabel.textColor = [UIColor redColor];
            self.dateLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:self.dateLabel];
            
            UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-30, general_margin, general_space, general_space)];
            arrowImgView.image = [UIImage imageNamed:@"icon_arrow"];
            [cell.contentView addSubview:arrowImgView];
            
            UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
            downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
            [cell.contentView addSubview:downLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;

    }else if (indexPath.section == 3){
        static NSString *daozhenjutishijianID = @"daozhenjutishijian";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:daozhenjutishijianID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:daozhenjutishijianID];
            
            self.timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 200, 50)];
            self.timeTitleLabel.text = @"到诊具体时间";
            self.timeTitleLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.timeTitleLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
            self.timeTitleLabel.backgroundColor = [UIColor clearColor];
            self.timeTitleLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:self.timeTitleLabel];
            
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 50)];
            self.timeLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.timeLabel.backgroundColor = [UIColor clearColor];
            self.timeLabel.textColor = [UIColor redColor];
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:self.timeLabel];
            
            UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-30, general_margin, general_space, general_space)];
            arrowImgView.image = [UIImage imageNamed:@"icon_arrow"];
            [cell.contentView addSubview:arrowImgView];
            UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
            downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
            [cell.contentView addSubview:downLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    
    }else if (indexPath.section == 4){
        static NSString *paytypeID = @"paytype";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paytypeID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paytypeID];
            
            self.payTypeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 50)];
            self.payTypeTitleLabel.text = @"支付方式";
            self.payTypeTitleLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.payTypeTitleLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
            [cell.contentView addSubview:self.payTypeTitleLabel];
            
            self.payTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 50)];
            self.payTypeLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.payTypeLabel.backgroundColor = [UIColor whiteColor];
            self.payTypeLabel.textColor = [UIColor blackColor];
            self.payTypeLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:self.payTypeLabel];
            
            UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-30, general_margin, general_space, general_space)];
            arrowImgView.image = [UIImage imageNamed:@"icon_arrow"];
            [cell.contentView addSubview:arrowImgView];
            UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
            downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
            [cell.contentView addSubview:downLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;

    }else if (indexPath.section == 5){
        static NSString *youhuiquanID = @"youhuiquan";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:youhuiquanID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:youhuiquanID];
            self.youhuiTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 50)];
            self.youhuiTitleLabel.text = @"优惠券";
            self.youhuiTitleLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.youhuiTitleLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
            [cell.contentView addSubview:self.youhuiTitleLabel];
            
            self.youhuiquanLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 50)];
            self.youhuiquanLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.youhuiquanLabel.backgroundColor = [UIColor whiteColor];
            self.youhuiquanLabel.textColor = [UIColor blackColor];
            self.youhuiquanLabel.textAlignment = NSTextAlignmentRight;
            self.youhuiquanLabel.text = @"-¥0";
            [cell.contentView addSubview:self.youhuiquanLabel];
            
            UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-30, general_margin, general_space, general_space)];
            arrowImgView.image = [UIImage imageNamed:@"icon_arrow"];
            [cell.contentView addSubview:arrowImgView];
            UIView *downLine = [[UIView alloc] initWithFrame:CGRectMake(general_margin, 49, screen_width-general_margin, splite_line_height)];
            downLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
            [cell.contentView addSubview:downLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else if (indexPath.section == 6){
        static NSString *addressID = @"address";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addressID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressID];
            self.addressTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 50)];
            self.addressTitleLabel.text = @"地址";
            self.addressTitleLabel.font = [UIFont systemFontOfSize:default_1_font_size];
            self.addressTitleLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
            [cell.contentView addSubview:self.addressTitleLabel];
            
            self.addressField = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 50)];
            self.addressField.font = [UIFont systemFontOfSize:default_1_font_size];
            self.addressField.backgroundColor = [UIColor whiteColor];
            self.addressField.textColor = [UIColor blackColor];
            self.addressField.delegate = self;
            self.addressField.textAlignment = NSTextAlignmentRight;
            self.addressField.placeholder = @"如需上门请填写地址";
            [self.addressField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView addSubview:self.addressField];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
   
    }else if (indexPath.section == 7){
        if (indexPath.row == 0) {
            static NSString *paymentID = @"orginAmount";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paymentID];
                
                UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 30)];
                sexLabel.text = @"金额";
                sexLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                //            sexLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
                sexLabel.textColor = [UIColor blackColor];
                [cell.contentView addSubview:sexLabel];
                
                self.orginPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 30)];
                self.orginPriceLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                self.orginPriceLabel.backgroundColor = [UIColor whiteColor];
                self.orginPriceLabel.textColor = [UIColor blackColor];
                self.orginPriceLabel.textAlignment = NSTextAlignmentRight;
                self.orginPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",self.project.specialPrice];
                [cell.contentView addSubview:self.orginPriceLabel];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }else if (indexPath.row == 1){
            static NSString *paymentID = @"discountAmount";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paymentID];
                
                UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 30)];
                sexLabel.text = @"已优惠";
                sexLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                //            sexLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
                sexLabel.textColor = [UIColor blackColor];
                [cell.contentView addSubview:sexLabel];
                
                self.discountPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 30)];
                self.discountPriceLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                self.discountPriceLabel.backgroundColor = [UIColor whiteColor];
                self.discountPriceLabel.textColor = [UIColor blackColor];
                self.discountPriceLabel.textAlignment = NSTextAlignmentRight;
                self.discountPriceLabel.text = @"¥0";
                [cell.contentView addSubview:self.discountPriceLabel];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        else{
            static NSString *paymentID = @"payment";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paymentID];
                
                UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(general_margin, 0, 100, 30)];
                sexLabel.text = @"应付";
                sexLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                //            sexLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
                [cell.contentView addSubview:sexLabel];
                
                self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-30-200, 0, 200, 30)];
                self.priceLabel.font = [UIFont systemFontOfSize:default_1_font_size];
                self.priceLabel.backgroundColor = [UIColor whiteColor];
                self.priceLabel.textColor = [UIColor redColor];
                self.priceLabel.textAlignment = NSTextAlignmentRight;
                self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",self.project.specialPrice];
                [cell.contentView addSubview:self.priceLabel];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
    }
    else{
        UITableViewCell *cell = [UITableViewCell new];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 215;
        }else{
            return 50;
        }
    }else if (indexPath.section == 7){
        return 30;
    }
    else{
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 7) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 10)];
        headerView.backgroundColor = [ColorUtils colorWithHexString:common_bg_color];
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 7) {
        return 10;
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        MHActionSheet *actionSheet = [[MHActionSheet alloc] initSheetWithTitle:nil style:MHSheetStyleWeiChat itemTitles:@[@"女",@"男"]];
        [actionSheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
            NSLog(@">>>>>>>>>>>>>>>%@",title);
            self.sexTitleLabel.text = title;
            self.sexLabel.text = @"就诊人性别";
            self.sexLabel.textColor = [UIColor blackColor];
        }];
    }else if (indexPath.section == 2){
        [self tapDatePickerView:UIDatePickerModeDate type:date_type];
    }else if (indexPath.section == 3){
        [self tapDatePickerView:UIDatePickerModeTime type:time_type];
    }else if (indexPath.section == 4){
        SelectPayTypeController *sptvc = [[SelectPayTypeController alloc] initWithFromType:account_session_from_project_order_vc];
        [self.navigationController pushViewController:sptvc animated:YES];
    }else if (indexPath.section == 5){
        SelectCouponController *scvc = [[SelectCouponController alloc] initWithFromType:account_session_from_project_order_vc];
        [self.navigationController pushViewController:scvc animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    //emoji无效
    if([NSStringUtils isContainsEmoji:string])
        
    {
        return NO;
        
    }else{
        if (textField == self.phoneTextField || textField == self.ageTextField) {
            if (![self validateNumber:string]) {
               return NO;
            }else{
                return YES;
            }
        }
        else{
            return YES;
        }
    }
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}


-(void)textFieldDidChanged:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        if (self.nameTextField.text.length == 0 || self.nameTextField.text == nil || [self.nameTextField.text isEqualToString:@""]) {
            self.nameLabel.text = @"请输入就诊人姓名";
            self.nameLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
        }else{
            self.nameLabel.text = @"就诊人姓名";
            self.nameLabel.textColor = [UIColor blackColor];
            NSLog(@">>>>>self.nameTextField.text111>>>>>>%@",self.nameTextField.text);
            if (self.nameTextField.text.length > 10) {
                [self.view makeToast:@"最多10个字！" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
                self.nameTextField.text = [self.nameTextField.text substringToIndex:10];
                NSLog(@">>>>>self.nameTextField.text222>>>>>>%@",self.nameTextField.text);
            }
        }
    }else if (textField == self.phoneTextField){
        if (self.phoneTextField.text.length == 0 || self.phoneTextField.text == nil || [self.phoneTextField.text isEqualToString:@""]) {
            self.phoneLabel.text = @"请输入就诊人电话";
            self.phoneLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
        }else{
            self.phoneLabel.text = @"就诊人电话";
            self.phoneLabel.textColor = [UIColor blackColor];
            if (self.phoneTextField.text.length > 11) {
                [self.view makeToast:@"最多11位！" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
                self.phoneTextField.text = [self.phoneTextField.text substringToIndex:11];
            }

        }

    }else if (textField == self.ageTextField){
        if (self.ageTextField.text.length == 0 || self.ageTextField.text == nil || [self.ageTextField.text isEqualToString:@""]) {
            self.ageLabel.text = @"请输入就诊人年龄";
            self.ageLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
        }else{
            self.ageLabel.text = @"就诊人年龄";
            self.ageLabel.textColor = [UIColor blackColor];
            if (self.ageTextField.text.length > 3) {
                [self.view makeToast:@"最多3位！" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
                self.ageTextField.text = [self.ageTextField.text substringToIndex:3];
            }
        }
    }else{
        if (self.addressField.text.length == 0 || self.addressField.text == nil || [self.addressField.text isEqualToString:@""]) {
            self.addressTitleLabel.text = @"地址";
            self.addressTitleLabel.textColor = [ColorUtils colorWithHexString:@"#bbbbbb"];
        }else{
            self.addressTitleLabel.text = @"地址";
            self.addressTitleLabel.textColor = [UIColor blackColor];
        }
    }

}


- (void)initBottomBtnView{
    UIView *upLine = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-59, screen_width, splite_line_height)];
    upLine.backgroundColor = [ColorUtils colorWithHexString:splite_line_color];
    [self.view addSubview:upLine];
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmBtn.frame = CGRectMake(general_margin, screen_height-7-45, screen_width-2*general_margin, 45);
    UIImage *hightLightImage = [UIImage imageNamed:@"btn_login_pre"];
    [self.confirmBtn setBackgroundImage:[ImageUtils resizableBgImage:hightLightImage] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundImage:[ImageUtils resizableBgImage:hightLightImage] forState:UIControlStateHighlighted];
    [self.confirmBtn setTitle:@"立即预约" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:bigger_font_size]];
    [self.confirmBtn addTarget:self action:@selector(confirmOrderBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmBtn];
}

- (void)confirmOrderBtnClick{
    NSLog(@"-----------%@---%@--%@--%@--%@---%@---%@",self.nameTextField.text,self.phoneTextField.text,self.ageTextField.text,self.sexTitleLabel.text,self.dateLabel.text,self.timeLabel.text,self.selectedPayTypeStr);
    
    NewProjectOrder *project = [[NewProjectOrder alloc] init];
    project.userId = [AppStatus sharedInstance].user.id;
    project.projectId = self.projectId;
    project.organizationId = self.project.organizationId;
    project.orderName = self.nameTextField.text;
    project.orderMobileNo = self.phoneTextField.text;
    project.orderAge = [self.ageTextField.text intValue];
    int gender = 0;
    if ([self.sexTitleLabel.text isEqualToString:@"男"]) {
        gender = 1;
    }else{
        gender = 0;
    }
    project.orderGender = gender;
    
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",[self.dateLabel.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"],self.timeLabel.text];
    NSDate *date = [DateUtils getNewDateByString:dateStr];
    long long int timeTmp = [DateUtils longlongintFromDate:date];
    NSString *tmp = [DateUtils dateWithStringFromLongLongInt:timeTmp];
    NSLog(@">>>>>>>>>>>扎UN哈UN后的时间>>>%@>>>>%@-----%lld",date,tmp,timeTmp);
    project.orderTime = timeTmp;
    NSString *tmptttt = [DateUtils dateWithStringFromLongLongInt:project.orderTime];
    NSLog(@">>>>>>>>>>>获取时间>>>>>>>%@",tmptttt);
    project.price = self.project.price;
    project.specialOfferPrice = self.project.specialPrice;
    project.redEnvelopeAmount = [[self.youhuiquanLabel.text substringFromIndex:2] intValue];
    project.orderAddress = self.addressField.text;
    project.orderPrice = [[self.priceLabel.text substringFromIndex:1] floatValue];
    
    NSLog(@"-----------%d---%.2f",[[self.youhuiquanLabel.text substringFromIndex:2] intValue],[[self.priceLabel.text substringFromIndex:1] floatValue]);
    
    if (self.nameTextField.text == nil || self.nameTextField.text.length == 0) {
        [self.view makeToast:@"姓名不能为空" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }
    if (self.phoneTextField.text == nil || self.phoneTextField.text.length == 0) {
        [self.view makeToast:@"手机号不能为空" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }else if (self.phoneTextField.text.length != 11){
        [self.view makeToast:@"请输入正确的手机号..." duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }
    
    if (self.sexTitleLabel.text == nil || self.sexTitleLabel.text == 0) {
        [self.view makeToast:@"性别不能为空" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }
    
    if (self.dateLabel.text == nil || self.dateLabel.text == 0) {
        [self.view makeToast:@"就诊日期不能为空" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }
    if (self.timeLabel.text == nil || self.timeLabel.text == 0) {
        [self.view makeToast:@"具体时间不能为空" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }
    
    NSString *paymentType;
    if ([self.selectedPayTypeStr isEqualToString:@"钱包支付"]) {
        paymentType = @"userAccount";
        if (self.userAccount.balance < [[self.priceLabel.text substringFromIndex:1] floatValue]) {
            [self.view makeToast:@"余额不足，请选择其他支付方式！" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
            return;
        }
    }else{
        paymentType = @"";
    }
    if (self.payTypeLabel.text == nil || self.payTypeLabel.text == 0) {
        [self.view makeToast:@"请选择支付方式" duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        return;
    }
    [SVProgressHUD showWithStatus:@"提交中..." maskType:SVProgressHUDMaskTypeClear];
    [OrderStore confirmOrderProject:^(ProjectOrder *project, NSError *err) {
        [SVProgressHUD dismiss];
        if (project != nil) {
            self.projectOrder = project;
            NSLog(@">>>>>>>>self.projectOrder：%@",self.projectOrder);
            if (project.orderPrice != 0) {
                PayProcessor *payProcessor = [PayProcessor sharedInstance];
                if ([self.selectedPayTypeStr isEqualToString:TEN_PAYMENT]) {
                    WeiXinPayProcessor * wxpay = [WeiXinPayProcessor sharedInstance];
                    wxpay.delegate = payProcessor;
                    [wxpay doWeixinpay:@"疯狂太医" outTradeNo:self.projectOrder.orderNo totalPrice:project.orderPrice buyer:[AppStatus sharedInstance].user.name tradeType:@"APP" type:type_project navigationController:self.navigationController];
                }else if([self.selectedPayTypeStr isEqualToString:ALI_APP_PAYMENT]){
                    AlipayProceessor *ap = [AlipayProceessor sharedInstance];
                    AlixPayOrder *payOrder = [ap buildAlixPayOrderByProjectOrder:self.projectOrder type:type_project subject:self.projectOrder.projectName];
                    [ap doAlipay:payOrder paymentType:self.selectedPayTypeStr type:type_project navigationController:self.navigationController];
                }else{
                    [self popSuccessView];
                }
            }else{
                [self popSuccessView];
            }
        }else{
            ExceptionMsg *exception = [[err userInfo] objectForKey:@"ExceptionMsg"];
            [self.view makeToast:exception.message duration:2.0 position:[NSValue valueWithCGPoint:self.view.center]];
        }
    } project:project redEnvelopeId:self.tmpRedCouponId paymentType:paymentType];
}

- (void)popSuccessView{
    self.popUpView = [[PopUpView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    [self.view addSubview:self.popUpView];
    
    self.xbPopView = [[XbPopView alloc] initWithFrame:CGRectMake((screen_width-280)/2, 205, 280, 155) remindImg:@"bg_word_subscribe_success"];
    self.xbPopView.userInteractionEnabled = YES;
    self.xbPopView.delegate = self;
    if (self.isClick == NO) {
        [self performSelector:@selector(didCancelBtnClick:) withObject:nil afterDelay:3.0f];
    }
    //下拉动画
    [UIView animateWithDuration:0.2 animations:^{
        self.xbPopView.center =  CGPointMake(screen_width/2, screen_height/2);
    }];
    [self.view addSubview:self.xbPopView];
    [self.view bringSubviewToFront:self.xbPopView];
}

- (void)didCancelBtnClick:(UIButton *)sender{
    [self.popUpView removeFromSuperview];
    [self.xbPopView removeFromSuperview];
    
    CrazyDoctorTabbar *tabBar = [(AppDelegate*)[UIApplication sharedApplication].delegate tabbar];
    //将当前的视图堆栈pop到根视图
    if ([tabBar.tabBarController selectedIndex] != tabbar_item_index_me) {
        UINavigationController *navController = [tabBar getSelectedViewController];
        [navController popToRootViewControllerAnimated:NO];
    }
    [tabBar.tabBarController setSelectedIndex:tabbar_item_index_me];
    
    UINavigationController *navController = [tabBar getSelectedViewController];
    
    NSString *url = [NSString stringWithFormat:@"%@/myOrders?Authorization=%@&isAppOpen=1&noHeaderFlag=1&noLocationFlag=0&orderType=projects",[AppStatus sharedInstance].wxpubUrl,[AppStatus sharedInstance].user.accessToken];
    MyOrdersController *mcvc = [[MyOrdersController alloc] initWithUrl:url];
    [navController pushViewController:mcvc animated:YES];
    [tabBar.tabBarController setTabBarHidden:YES animated:YES];
    self.isClick = YES;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didCancelBtnClick:) object:nil];
}

/**
 *  时间选择器
 *
 *  @return
 */
//弹出-------datePickerView
#pragma mark - datePickerView   处理Date
-(void)tapDatePickerView:(UIDatePickerMode)model type:(int)type{
    self.pickerType = type;
    CGRect maskFrame = self.maskView.frame;
    maskFrame.size.height = screen_height;
    maskFrame.size.width = screen_width;
    self.maskView.frame = maskFrame;
    self.maskView.alpha = 0.5;
    self.maskView.backgroundColor = [UIColor blackColor];
    [self.cancelDateBtn setTintColor:[UIColor blackColor]];
    [self.confirmDateBtn setTintColor:[ColorUtils colorWithHexString:common_app_text_color]];
    [self.view addSubview:self.maskView];
    self.datePickerView.datePickerMode = model;
    NSDate *date = [NSDate date];
    self.datePickerView.minimumDate = date;
    NSLocale *chineseLocale = [NSLocale currentLocale]; //创建一个中文的地区对象
    [self.datePickerView setLocale:chineseLocale]; //将这个地区对象给UIDatePicker设置上
    CGRect frame = self.chooseDateModalView.frame;
    frame.origin.y = self.view.frame.size.height;
    frame.size.width = screen_width;
    self.chooseDateModalView.frame = frame;
    [self.view addSubview:self.chooseDateModalView];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.chooseDateModalView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.chooseDateModalView.frame = frame;
    }];
}

- (IBAction)cancelDatePickerClick:(UIBarButtonItem *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.chooseDateModalView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.chooseDateModalView.frame = frame;
    } completion:^(BOOL finished) {
        [self.chooseDateModalView removeFromSuperview];
        [self.maskView removeFromSuperview];
    }];
    
}

- (IBAction)confirmDatePickerClick:(UIBarButtonItem *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.chooseDateModalView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.chooseDateModalView.frame = frame;
    } completion:^(BOOL finished) {
        NSDate *select = [self.datePickerView date]; // 获取被选中的时间
        NSString *dateString = [DateUtils getDateByPickerDate:select];
        NSArray *array = [dateString componentsSeparatedByString:@" "];
        if (self.pickerType == date_type) {
            NSString *dateStr = array[0];
           self.dateLabel.text = dateStr;
            self.dateTitleLabel.text = @"就诊日期";
            self.dateTitleLabel.textColor = [UIColor blackColor];
        }else if(self.pickerType == time_type){
            NSLog(@"-----------%@",array[1]);
            NSString *timeStr = array[1];
            self.timeLabel.text = timeStr;
            self.timeTitleLabel.text = @"到诊具体时间";
            self.timeTitleLabel.textColor = [UIColor blackColor];
        }
        
        [self.chooseDateModalView removeFromSuperview];
        [self.maskView removeFromSuperview];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
    }else if (textField == self.phoneTextField){
        [self.phoneTextField resignFirstResponder];
    }else{
        [self.ageTextField resignFirstResponder];
    }
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
