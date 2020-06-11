//
//  BBZBaseAsset.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

extern const int BBZMinVideoTime;
//extern const int BBZVideoTimeScale;
extern const int BBZVideoDurationScale;
extern const int BBZScheduleTimeScale;
//extern const int BBZActionTimeToScheduleTime;

typedef NS_ENUM(NSInteger, BBZBaseAssetMediaType) {
    BBZBaseAssetMediaTypeUnknown = 0,
    BBZBaseAssetMediaTypeImage   = 1,
    BBZBaseAssetMediaTypeVideo   = 2,
    BBZBaseAssetMediaTypeAudio   = 3,
};


/*资源的描述，最好不要在这里进行资源解压,在解码类进行实际解码及分辩率调整
    资源变速暂时未实现
 */
@interface BBZBaseAsset : NSObject
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, assign) BBZBaseAssetMediaType mediaType;
@property (nonatomic, strong) NSString *filePath;
//@property (nonatomic, strong, readonly) NSObject *asset;
///当通过PHAsset创建实例时，此值为PHAsset资源的标识符
@property (nonatomic, strong) NSString *identifierOfPHAsset;

@property (nonatomic, assign) NSUInteger sourceDuration;
@property (nonatomic, assign) CMTimeRange sourceTimeRange;
@property (nonatomic, assign) NSUInteger playDuration;
@property (nonatomic, assign) CMTimeRange playTimeRange;

// 
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGSize sourceSize;

///timeline
@property (nonatomic, assign) NSTimeInterval timelineStart;
@property (nonatomic, assign) NSTimeInterval timelineDelay;
@property (nonatomic, assign) NSTimeInterval timelineDuration;
@property (nonatomic, readonly) NSTimeInterval timelineEnd;
@property (nonatomic, assign) NSInteger order;


- (instancetype)initWithFilePath:(NSString *)filePath;
+ (instancetype)assetWithFilePath:(NSString *)filePath;




@end

