//
//  BBZEngineSetting.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBZEngineSetting : NSObject

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) NSInteger videoBitRate;
@property (nonatomic, assign) NSInteger videoFrameRate;
@property (nonatomic, assign) NSInteger videoMaxKeyFrameInterval;
@property (nonatomic, assign) BOOL allowFrameReorder;

@property (nonatomic, assign) NSInteger audioBitRate;
@property (nonatomic, assign) NSInteger audioSampleRate;
@property (nonatomic, strong) NSString *profileLevel;

@property (nonatomic, strong) NSString *passthroughPresetName;
@property (nonatomic, readonly) NSInteger videoLongestEdge;
@property (nonatomic, readonly) NSDictionary *videoOutputSettings;
@property (nonatomic, readonly) NSDictionary *audioOutputSettings;

+ (instancetype)passthroughVideoSettings;
+ (instancetype)engineSettingsWithPassthroughPresetName:(NSString *)presetName;



///helper 
+ (NSInteger)perfectAudioBitRate;
+ (NSInteger)perfectVideoBitRate;
+ (NSInteger)perfectResolutionForRenderSize;
+ (NSInteger)maxResolution;

+ (NSInteger)perfectResolutionForImage;
+ (NSInteger)maxResolutionForImage;

@end

NS_ASSUME_NONNULL_END
