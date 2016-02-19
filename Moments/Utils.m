//
//  Utils.m
//  Moments
//
//  Created by Thomson on 16/2/17.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIColor *) HexColorToRedGreenBlue:(NSString *)hexColorString
{
    NSString *cString = [[hexColorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return nil;
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int red, green, blue;
    [[NSScanner scannerWithString:rString] scanHexInt:&red];
    [[NSScanner scannerWithString:gString] scanHexInt:&green];
    [[NSScanner scannerWithString:bString] scanHexInt:&blue];
    
    return [UIColor colorWithRed:((float) red / 255.0f) green:((float) green / 255.0f) blue:((float) blue / 255.0f) alpha:1.0f];
}

+ (NSString *)timeWithDate:(NSDate *)date
{
    if (date == nil)
    {
        return @"";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSDate *now = [NSDate date];
    
    NSCalendarUnit unit = NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [calendar components:unit fromDate:now];
    NSInteger nowHour = components.hour;
    NSInteger nowMinute = components.minute;
    NSInteger nowSecond = components.second;
    NSInteger nowWeekday = components.weekday;
    
    components = [calendar components:unit fromDate:date];
    NSInteger dateHour = components.hour;
    NSInteger dateMinute = components.minute;
    NSInteger dateWeekday = components.weekday;
    
    NSTimeInterval interval = [now timeIntervalSinceDate:date];
    
    NSString *result = @"";
    if (interval > 24*60*60*7)
    {
        //一个星期之前显示全部时间
        result = [formatter stringFromDate:date];
    }
    else if(interval >= 24*60*60*1+nowHour*60*60+nowMinute*60+nowSecond)//大于等于2天
    {
        //上个星期
        if(nowWeekday<dateWeekday)
        {
            result = [formatter stringFromDate:date];
        }
        else    //本星期要显示星期
        {
            result = [NSString stringWithFormat:@"%@ %02zi:%02zi", [self stringedWeekday:dateWeekday], dateHour, dateMinute];
        }
    }
    else if(interval >= nowHour*60*60+nowMinute*60+nowSecond)    //昨天
    {
        result = [NSString stringWithFormat:@"%@ %02zi:%02zi", @"昨天", dateHour, dateMinute];
    }
    else
    {
        result = [NSString stringWithFormat:@"%02zi:%02zi", dateHour, dateMinute];
    }
    
    return result;
}

+ (NSString *)stringedWeekday:(NSUInteger)weekday
{
    assert(weekday>=1 && weekday<=7);
    
    return @[@"星期日",
             @"星期一",
             @"星期二",
             @"星期三",
             @"星期四",
             @"星期五",
             @"星期六"][weekday-1];
}

@end
