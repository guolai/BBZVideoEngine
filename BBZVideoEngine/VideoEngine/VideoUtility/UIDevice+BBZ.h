//
//  UIDevice+BBZ.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, kBBZDeviceLevel) {
    kBBZDeviceLeveliPhone4 = 4,
    kBBZDeviceLeveliPhone4s = 5,
    kBBZDeviceLeveliPhone5 = 6,
    kBBZDeviceLeveliPhone5s = 7,
    kBBZDeviceLeveliPhone6 = 8,
    kBBZDeviceLeveliPhone6p = 9,
    kBBZDeviceLeveliPhoneSE = 10,
    kBBZDeviceLeveliPhone6s = 11,
    kBBZDeviceLeveliPhone6sp = 12,
    kBBZDeviceLeveliPhone7 = 13,
    kBBZDeviceLeveliPhone7p = 14,
    kBBZDeviceLeveliPhone8 = 15,
    kBBZDeviceLeveliPhone8p = 16,
    kBBZDeviceLeveliPhoneX = 17,
    kBBZDeviceLeveliPhone11 = 18,
};


@interface UIDevice (BBZ)

+ (NSString *)getDeviceString;
+ (NSInteger)getDeviceLevel;

@end

NS_ASSUME_NONNULL_END
