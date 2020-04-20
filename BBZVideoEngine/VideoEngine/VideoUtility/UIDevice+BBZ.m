//
//  UIDevice+BBZ.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "UIDevice+BBZ.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>


@implementation UIDevice (BBZ)
+ (NSString *)getDeviceString {
    static NSString *deviceModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    });
    //iPhone 系列
    if ([deviceModel isEqualToString:@"iPhone1,1"])    return @"iPhone";
    if ([deviceModel isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceModel isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (GSM)";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (GSM)";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone11 Pro Max";
    
    //iPod 系列
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    //iPad 系列
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceModel isEqualToString:@"iPad4,4"]
        ||[deviceModel isEqualToString:@"iPad4,5"]
        ||[deviceModel isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceModel isEqualToString:@"iPad4,7"]
        ||[deviceModel isEqualToString:@"iPad4,8"]
        ||[deviceModel isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    return deviceModel;
}

/* to do 这里需要再核对一下*/
+ (NSInteger)getDeviceLevel {
    static dispatch_once_t onceToken;
    static NSInteger level;
    dispatch_once(&onceToken, ^{
        NSString *deviceType = [UIDevice getDeviceString];
        if ([deviceType isEqualToString:@"iPhone"]) level = 2;
        else if ([deviceType containsString:@"iPhone 3G"]) level = 2;
        else if ([deviceType containsString:@"iPhone 3GS"]) level = 3;
        else if ([deviceType containsString:@"iPhone 4"]) level = 4;   //A4
        else if ([deviceType containsString:@"iPhone 4S"]) level = 5;  //A5
        else if ([deviceType containsString:@"iPhone 5"]) level = 6;   //A6
        else if ([deviceType containsString:@"iPhone 5C"]) level = 6;
        else if ([deviceType containsString:@"iPhone 5S"]) level = 7;
        else if ([deviceType containsString:@"iPhone 6 Plus"]) level = kBBZDeviceLeveliPhone6p;
        else if ([deviceType isEqualToString:@"iPhone 6"]) level = kBBZDeviceLeveliPhone6;
        
        else if ([deviceType containsString:@"iPhone 6S Plus"]) level = kBBZDeviceLeveliPhone6sp;
        else if ([deviceType containsString:@"iPhone 6S"]) level = kBBZDeviceLeveliPhone6s;
    
        else if ([deviceType containsString:@"iPhone SE"]) level = kBBZDeviceLeveliPhoneSE;
        else if ([deviceType containsString:@"iPhone 7 Plus"]) level = kBBZDeviceLeveliPhone7p;
        else if ([deviceType containsString:@"iPhone 7"]) level = kBBZDeviceLeveliPhone7;
        
        else if ([deviceType containsString:@"iPhone 8S Plus"]) level = kBBZDeviceLeveliPhone8p;
        else if ([deviceType containsString:@"iPhone 8"]) level = kBBZDeviceLeveliPhone8;
        
        else if ([deviceType containsString:@"iPhone X"]) level = kBBZDeviceLeveliPhoneX;
        else if ([deviceType containsString:@"iPhone11"]) level = kBBZDeviceLeveliPhone11;
        
        else if ([deviceType isEqualToString:@"iPad"]) level = 4;
        else if ([deviceType containsString:@"iPad 2"]) level = 5;
        else if ([deviceType containsString:@"iPad 3"]) level = 5;
        else if ([deviceType containsString:@"iPad 4"]) level = 6;
        else if ([deviceType containsString:@"iPad Air"]) level = 7;
        else if ([deviceType containsString:@"iPad Air 2"]) level = 8;
        else if ([deviceType containsString:@"iPad mini"]) level = 5;
        else if ([deviceType containsString:@"iPad Pro"]) level = 9;
        
        else if ([deviceType isEqualToString:@"iPodTouch"]) level = 1;
        else if ([deviceType containsString:@"iPodTouch 2"]) level = 2;
        else if ([deviceType containsString:@"iPodTouch 3"]) level = 3;
        else if ([deviceType containsString:@"iPodTouch 4"]) level = 4;
        else if ([deviceType containsString:@"iPodTouch 5"]) level = 5;
        else if ([deviceType containsString:@"iPodTouch 6"]) level = 8;
        
        else level = 10;
    });
    return level;
}

@end
