//
//  DateUtils.m
//  styler
//
//  Created by aypc on 13-10-16.
//  Copyright (c) 2013年 mlzj. All rights reserved.
//

#import "DateUtils.h"
#import "TimeUtils.h"
@implementation DateUtils

-(id)initWithDate:(NSDate *)date
{
    self = [self init];
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy,MM,dd"];
    NSString * dateStr = [df stringFromDate:date];
    NSArray * dateArray = [dateStr componentsSeparatedByString:@","];
    self.year = [[dateArray objectAtIndex:0]intValue];
    self.month = [[dateArray objectAtIndex:1]intValue];
    self.day = [[dateArray objectAtIndex:2]intValue];
    self.week = [self weekDayFromDate:date];
    self.date = date;
    return self;
}
-(int)weekDayFromDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [weekdayComponents weekday];
    
    return weekday;
}

-(BOOL)isEqualToDateUtils:(DateUtils *)DU
{
    if ((self.year == DU.year)&&(self.month == DU.month)&&(self.day == DU.day)) {
        return YES;
    }else
    {
        return NO;
    }
}

+(int)daysOfMonthWithDate:(NSDate *)date
{
    DateUtils * du = [[DateUtils alloc]initWithDate:date];
    
    if (du.month == 1 || du.month == 3 || du.month == 5|| du.month == 7|| du.month == 8|| du.month == 10|| du.month == 12) {
        return 31;
    }else if(du.month == 2){
        if (du.year % 400 == 0) {
            return 29;
        }else if(du.year % 4 ==0)
        {
            return 29;
        }else
        {
            return 28;
        }
    }else
    {
        return 30;
    }
    
}
+(NSString *)weekDayStringWithWeek:(int)week
{
    switch (week) {
        case 1:
            return @"星期日";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
            
        default:
            return nil;
            break;
    }
}

+(NSString *)stringFromDate:(NSDate *)date{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *minuteComponents = [gregorian components:NSMinuteCalendarUnit fromDate:date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    if (minuteComponents.minute == 0) {
        [dateFormatter setDateFormat:@"yyyy年M月d日 H点 EEE"];
    }else if(minuteComponents.minute == 30){
        [dateFormatter setDateFormat:@"yyyy年M月d日 H点半 EEE"];
    }else{
        [dateFormatter setDateFormat:@"yyyy年M月d日 H点 EEE"];
    }
    
    return [dateFormatter stringFromDate:date];
}


+(NSString *)stringFromLongLongInt:(long long int)date{
    NSDate *temp = [[NSDate alloc]initWithTimeIntervalSince1970:date/1000.0];
    return [DateUtils stringFromDateAndFormat:temp dateFormat:@"yyyy年M月d日"];
}

+(NSString *)stringFromNumber:(NSNumber *)date{
    NSDate *temp = [[NSDate alloc]initWithTimeIntervalSince1970:date.longLongValue/1000.0];
    return [DateUtils stringFromDateAndFormat:temp dateFormat:@"yyyy年M月d日"];
}

+(NSString *)stringFromDateAndFormat:(NSDate *)date dateFormat:(NSString *)dateFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return [dateFormatter stringFromDate:date];
}

+(NSString *)stringFromLongLongIntAndFormat:(long long int)date dateFormat:(NSString *)dateFormat{
    NSDate *temp = [[NSDate alloc]initWithTimeIntervalSince1970:date/1000.0];
    return [DateUtils stringFromDateAndFormat:temp dateFormat:dateFormat];
}

+(NSString *)stringFromNumberAndFormat:(NSNumber *)date dateFormat:(NSString *)dateFormat{
    NSDate *temp = [[NSDate alloc]initWithTimeIntervalSince1970:date.longLongValue/1000.0];
    return [DateUtils stringFromDateAndFormat:temp dateFormat:dateFormat];
}


+(NSDate *)dateFromLongLongInt:(long long int)date{
    return [[NSDate alloc]initWithTimeIntervalSince1970:date/1000.0];
}

+(long long int)longlongintFromDate:(NSDate *)date{
    return [date timeIntervalSince1970] * 1000;
}


+(int) compare:(NSDate *)date1 date2:(NSDate *)date2{
    if ([date1 isEqualToDate:date2]) {
        return 0;  // 两日期相等
    }else {
        NSDate *result = [date1 earlierDate:date2];
        if ([result isEqualToDate:date1]) {
            return 1;  // 第一个日期比第二个日期早
        }else{
            return 2;  // 第一个日期比第二个日期晚
        }
    }
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"year = %d,month = %d,day = %d,week = %d",self.year,self.month,self.day,self.week];
}
@end
