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
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
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
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";//se
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
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
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone12";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone12";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone12 Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone12 Pro Max";
    
    
    //iPod 系列
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPodTouch 1";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPodTouch 2";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPodTouch 3";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPodTouch 4";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPodTouch 5";
    if ([deviceModel isEqualToString:@"iPod7,1"])      return @"iPodTouch 6";
    if ([deviceModel isEqualToString:@"iPod9,1"])      return @"iPodTouch 7";
    
    //iPad 系列
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad mini";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad mini";
    
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4";
    
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,4"]
        ||[deviceModel isEqualToString:@"iPad4,5"]
        ||[deviceModel isEqualToString:@"iPad4,6"])    return @"iPad mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"]
        ||[deviceModel isEqualToString:@"iPad4,8"]
        ||[deviceModel isEqualToString:@"iPad4,9"])    return @"iPad mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"]
        ||[deviceModel isEqualToString:@"iPad5,2"])    return @"iPad mini 4";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    
    
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro";
    if ([deviceModel isEqualToString:@"iPad7,1"])      return @"iPad Pro 2";
    if ([deviceModel isEqualToString:@"iPad7,2"])      return @"iPad Pro 2";
    if ([deviceModel isEqualToString:@"iPad7,3"])       return @"iPad Pro";
    if ([deviceModel isEqualToString:@"iPad7,4"])       return @"iPad Pro";
    if ([deviceModel isEqualToString:@"iPad7,5"])       return @"iPad 6";
    if ([deviceModel isEqualToString:@"iPad7,6"])       return @"iPad 6";
    if ([deviceModel isEqualToString:@"iPad7,11"])      return @"iPad 7";
    if ([deviceModel isEqualToString:@"iPad7,12"])      return @"iPad 7";
    if ([deviceModel isEqualToString:@"iPad8,1"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,2"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,3"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,4"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,5"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,6"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,7"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad8,8"])       return @"iPad Pro 3";
    if ([deviceModel isEqualToString:@"iPad11,1"])      return @"iPad mini 5";
    if ([deviceModel isEqualToString:@"iPad11,2"])      return @"iPad mini 5";
    if ([deviceModel isEqualToString:@"iPad11,3"])      return @"iPad Air 3";
    if ([deviceModel isEqualToString:@"iPad11,4"])      return @"iPad Air 3";
    
    
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    
    
    if ([deviceModel hasPrefix:@"iPhone"])           return @"new iPhone";
    if ([deviceModel hasPrefix:@"iPod"])            return @"new iPod";
    if ([deviceModel hasPrefix:@"iPad"])            return @"new iPad";
   
    
    return deviceModel;
}

/* to do 这里需要再核对一下*/
+ (NSInteger)getDeviceLevel {
    static dispatch_once_t onceToken;
    static NSInteger level;
    dispatch_once(&onceToken, ^{
        NSString *deviceType = [UIDevice getDeviceString];
        if ([deviceType isEqualToString:@"iPhone"]) level = 2;
        else if ([deviceType isEqualToString:@"iPhone 3G"]) level = 2;
        else if ([deviceType isEqualToString:@"iPhone 3GS"]) level = 3;
        else if ([deviceType isEqualToString:@"iPhone 4"]) level = 4;   //A4
        else if ([deviceType isEqualToString:@"iPhone 4S"]) level = 5;  //A5
        else if ([deviceType isEqualToString:@"iPhone 5"]) level = 6;   //A6
        else if ([deviceType isEqualToString:@"iPhone 5C"]) level = 6;
        else if ([deviceType isEqualToString:@"iPhone 5S"]) level = 7;
        else if ([deviceType isEqualToString:@"iPhone 6"]) level = kBBZDeviceLeveliPhone6;
        else if ([deviceType isEqualToString:@"iPhone 6 Plus"]) level = kBBZDeviceLeveliPhone6p;
        
        else if ([deviceType isEqualToString:@"iPhone 6S"]) level = kBBZDeviceLeveliPhone6s;
        else if ([deviceType isEqualToString:@"iPhone 6S Plus"]) level = kBBZDeviceLeveliPhone6sp;
        else if ([deviceType isEqualToString:@"iPhone SE"]) level = kBBZDeviceLeveliPhoneSE;
       
        else if ([deviceType isEqualToString:@"iPhone 7"]) level = kBBZDeviceLeveliPhone7;
        else if ([deviceType isEqualToString:@"iPhone 7 Plus"]) level = kBBZDeviceLeveliPhone7p;
        
        else if ([deviceType isEqualToString:@"iPhone 8"]) level = kBBZDeviceLeveliPhone8;
        else if ([deviceType isEqualToString:@"iPhone 8 Plus"]) level = kBBZDeviceLeveliPhone8p;
        
        
        else if ([deviceType isEqualToString:@"iPhone X"]) level = kBBZDeviceLeveliPhoneX;
        else if ([deviceType isEqualToString:@"iPhone XS"]) level = kBBZDeviceLeveliPhoneX;
        
        else if ([deviceType isEqualToString:@"iPhone XS Max"]) level = kBBZDeviceLeveliPhoneX;
        else if ([deviceType isEqualToString:@"iPhone XR"]) level = kBBZDeviceLeveliPhoneX;
        
        
        else if ([deviceType isEqualToString:@"iPhone11"]) level = kBBZDeviceLeveliPhone11;
        else if ([deviceType isEqualToString:@"iPhone11 Pro"]) level = kBBZDeviceLeveliPhone11;
        else if ([deviceType isEqualToString:@"iPhone11 Pro Max"]) level = kBBZDeviceLeveliPhone11;
        
        else if ([deviceType isEqualToString:@"iPhone12"]) level = kBBZDeviceLeveliPhone12;
        else if ([deviceType isEqualToString:@"iPhone12 Pro"]) level = kBBZDeviceLeveliPhone12;
        else if ([deviceType isEqualToString:@"iPhone12 Pro Max"]) level = kBBZDeviceLeveliPhone12;
    
        
        else if ([deviceType isEqualToString:@"iPad"]) level = 4;
        else if ([deviceType isEqualToString:@"iPad 2"]) level = 5;
        else if ([deviceType isEqualToString:@"iPad 3"]) level = 5;
        else if ([deviceType isEqualToString:@"iPad 4"]) level = 6;
        else if ([deviceType isEqualToString:@"iPad Air"]) level = 7;
        else if ([deviceType isEqualToString:@"iPad Air 2"]) level = 8; //A8X
        else if ([deviceType isEqualToString:@"iPad mini"]) level = 5;
        else if ([deviceType isEqualToString:@"iPad mini 2"]) level = 7;
        else if ([deviceType isEqualToString:@"iPad mini 3"]) level = 7;
        else if ([deviceType isEqualToString:@"iPad mini 4"]) level = 8;    //A8X
        else if ([deviceType isEqualToString:@"iPad Pro"]) level = 9;   //A9X
        else if ([deviceType isEqualToString:@"iPad Pro 2"]) level = 9;
        else if ([deviceType isEqualToString:@"iPad 6"]) level = 10;
        else if ([deviceType isEqualToString:@"iPad 7"]) level = 10;
        else if ([deviceType isEqualToString:@"iPad Pro 3"]) level = 10;
        else if ([deviceType isEqualToString:@"iPad mini 5"]) level = 10;
        else if ([deviceType isEqualToString:@"iPad Air 3"]) level = 10;
 
        
        else if ([deviceType isEqualToString:@"iPodTouch"]) level = 1;
        else if ([deviceType isEqualToString:@"iPodTouch 2"]) level = 2;
        else if ([deviceType isEqualToString:@"iPodTouch 3"]) level = 3;
        else if ([deviceType isEqualToString:@"iPodTouch 4"]) level = 4;
        else if ([deviceType isEqualToString:@"iPodTouch 5"]) level = 5;
        else if ([deviceType isEqualToString:@"iPodTouch 6"]) level = 8;
        else if ([deviceType isEqualToString:@"iPodTouch 7"]) level = 9;
        
        else if ([deviceType isEqualToString:@"new iPhone"]) level = kBBZDeviceLeveliPhoneNew;
        else if ([deviceType isEqualToString:@"new iPad"]) level = kBBZDeviceLeveliPhoneNew;
        else if ([deviceType isEqualToString:@"new iPod"]) level = kBBZDeviceLeveliPhoneNew;
        
        else level = kBBZDeviceLeveliPhoneSE;
    });
    return level;
}

@end
