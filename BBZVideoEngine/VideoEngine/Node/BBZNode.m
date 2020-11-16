//
//  BBZNode.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZNode.h"
#import "NSDictionary+BBZVE.h"
extern const int BBZVideoDurationScale;
extern const int BBZScheduleTimeScale;

NSString *const BBZFilterTransformSource = @"transformsource";
NSString *const BBZFilterBlendImage = @"blendimage";
NSString *const BBZFilterBlendVideo = @"blendvideo";
NSString *const BBZFilterBlendLeftRightVideo = @"blendlrvideo";
NSString *const BBZFilterBlendVideoAndImage = @"blendvideoandimage";
NSString *const BBZFilterTransition = @"transition";
NSString *const BBZFilterSplice = @"splice";
NSString *const BBZFilterLut = @"lut";
NSString *const BBZFilterMovieEnding = @"movieending";


@implementation BBZNodeAnimationParams

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if(self = [super init]) {
        self.param1 = [dic BBZVEdoubleValueForKey2:@"param1" default:0.0];
        self.param2 = [dic BBZVEdoubleValueForKey2:@"param2" default:0.0];
        self.param3 = [dic BBZVEdoubleValueForKey2:@"param3" default:0.0];
        self.param4 = [dic BBZVEdoubleValueForKey2:@"param4" default:0.0];
        self.param5 = [dic BBZVEdoubleValueForKey2:@"param5" default:0.0];
        self.param6 = [dic BBZVEdoubleValueForKey2:@"param6" default:0.0];
        self.param7 = [dic BBZVEdoubleValueForKey2:@"param7" default:0.0];
        self.param8 = [dic BBZVEdoubleValueForKey2:@"param8" default:0.0];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    BBZNodeAnimationParams *copy = [[BBZNodeAnimationParams allocWithZone:zone] init];
    copy.param1 = self.param1;
    copy.param2 = self.param2;
    copy.param3 = self.param3;
    copy.param4 = self.param4;
    copy.param5 = self.param5;
    copy.param6 = self.param6;
    copy.param7 = self.param7;
    copy.param8 = self.param8;
    return copy;
}

@end

@implementation BBZNodeAnimation

-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.begin = [dic BBZVEdoubleValueForKey2:@"begin" default:0.0];
        self.end = [dic BBZVEdoubleValueForKey2:@"end" default:0.0];
        self.param_begin = [[BBZNodeAnimationParams alloc] initWithDictionary:dic[@"param_begin"]];
        self.param_end = [[BBZNodeAnimationParams alloc] initWithDictionary:dic[@"param_end"]];
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    BBZNodeAnimation *copyAnimation = [[BBZNodeAnimation alloc] init];
    copyAnimation.begin = self.begin;
    copyAnimation.end = self.end;
    copyAnimation.param_begin = self.param_begin;
    copyAnimation.param_end = self.param_end;
    return copyAnimation;
}

@end

//@interface BBZNode ()
//@property (nonatomic, assign) double offsetBegin;
//@end

@implementation BBZNode

- (void)initParams {
    self.begin = 0.0;
    self.end = 3600.0;
    self.order = 0;
    self.repeat = 1;
}

- (instancetype)init {
    if(self = [super init]) {
        [self initParams];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic withFilePath:(NSString *)filePath {
    if (self = [super init]) {
        [self initParams];
        _filePath = filePath;
        self.begin = [dic BBZVEdoubleValueForKey2:@"begin" default:0.0];
        self.end = [dic BBZVEdoubleValueForKey2:@"end" default:3600.0];
        self.order = [dic BBZVEintValueForKey:@"order" default:0];
        self.name = [dic BBZVEstringValueForKey:@"name" default:nil];
        self.fShader = [dic BBZVEstringValueForKey:@"fShader" default:nil];
        self.vShader = [dic BBZVEstringValueForKey:@"vShader" default:nil];
        self.scale_mode = [dic BBZVEstringValueForKey:@"scale_mode" default:nil];
        self.repeat = [dic BBZVEintValueForKey:@"repeat" default:1];
        self.attenmentFile = [dic BBZVEstringValueForKey:@"attenment" default:nil];
        id animationObj = [dic objectForKey:@"animation"];
        NSMutableArray *array = [NSMutableArray array];
        if ([animationObj isKindOfClass:[NSDictionary class]]) {
            BBZNodeAnimation *animation = [[BBZNodeAnimation alloc] initWithDictionary:animationObj];
            [array addObject:animation];
        } else if ([animationObj isKindOfClass:[NSArray class]]) {
            for (NSDictionary *aniDic in animationObj) {
                BBZNodeAnimation *animation = [[BBZNodeAnimation alloc] initWithDictionary:aniDic];
                [array addObject:animation];
            }
        }
        self.animations = array;
    }
    return self;
}

- (NSString *)vShaderString {
    NSError *error;
    NSString *shaderFilePath = [NSString stringWithFormat:@"%@/%@", self.filePath, self.vShader];
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFilePath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString)
    {
//        NSLog(@"Error: loading shader file:%@  %@",shaderFilePath, error.localizedDescription);
        return nil;
    }
    return shaderString;
}

- (NSString *)fShaderString {
    NSError *error;
    NSString *shaderFilePath = [NSString stringWithFormat:@"%@/%@", self.filePath, self.fShader];
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFilePath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString)
    {
//        NSLog(@"Error: loading shader file:%@  %@",shaderFilePath, error.localizedDescription);
        return nil;
    }
    return shaderString;
}

//- (double)offsetBegin {
//    return self.begin;
//}
//
//- (double)offsetEnd {
//    return self.end;
//}

- (CMTime)relativeTimeFromActionTime:(CMTime)actionTime {
    NSTimeInterval tmpTime = CMTimeGetSeconds(actionTime);
    NSInteger intTime = tmpTime * 1000;
    NSInteger intDuration = (self.end - self.begin) * 1000;
    NSInteger repeat = intTime / intDuration;
    if(repeat > self.repeat) {
        NSAssert(false, @"repeat error");
        return kCMTimeInvalid;
    }
    double offSet = repeat * (self.end - self.begin);
    tmpTime = tmpTime - offSet;
    CMTime retTime = CMTimeMake(tmpTime * BBZScheduleTimeScale, BBZScheduleTimeScale);
    return retTime;
}

- (BBZNodeAnimationParams *)paramsAtTime:(double)time {
    if(self.animations.count == 0) {
        return nil;
    }
    NSInteger intTime = time * 1000;
    NSInteger intDuration = (self.end - self.begin) * 1000;
    NSInteger repeat = intTime / intDuration;
    if(repeat > self.repeat) {
        NSAssert(false, @"error");
        return nil;;
    }
    double offSet = repeat * (self.end - self.begin);
    time = time - offSet;
    BBZNodeAnimation *nodeAnimation = [self.animations objectAtIndex:0];
    BBZNodeAnimationParams *currentTimeParam = [nodeAnimation.param_begin copy];
    if(self.begin > time) {
        NSAssert(false, @"error");
        return currentTimeParam;
    }
    if(self.end < time) {
        nodeAnimation = self.animations.lastObject;
        currentTimeParam = [nodeAnimation.param_end copy];
        NSAssert(false, @"error");
        return currentTimeParam;
    }
    for (int i = 0; i < self.animations.count; i++) {
        nodeAnimation = [self.animations objectAtIndex:i];
        if(time >= self.begin + nodeAnimation.begin && time <= self.begin + nodeAnimation.end) {
            break;
        }
    }
    
    if(!nodeAnimation) {
        NSCParameterAssert(nodeAnimation);
        return currentTimeParam;
    }
    BBZNodeAnimationParams *beginParam = nodeAnimation.param_begin;
    BBZNodeAnimationParams *endParam = nodeAnimation.param_end;
    double currentTime = time - self.begin - nodeAnimation.begin;
    double progress = currentTime / (nodeAnimation.end - nodeAnimation.begin);
    currentTimeParam = [[BBZNodeAnimationParams alloc] init];
    currentTimeParam.param1 = [self valueAtProgress:progress fromValue:beginParam.param1 toValue:endParam.param1];
    currentTimeParam.param2 = [self valueAtProgress:progress fromValue:beginParam.param2 toValue:endParam.param2];
    currentTimeParam.param3 = [self valueAtProgress:progress fromValue:beginParam.param3 toValue:endParam.param3];
    currentTimeParam.param4 = [self valueAtProgress:progress fromValue:beginParam.param4 toValue:endParam.param4];
    currentTimeParam.param5 = [self valueAtProgress:progress fromValue:beginParam.param5 toValue:endParam.param5];
    currentTimeParam.param6 = [self valueAtProgress:progress fromValue:beginParam.param6 toValue:endParam.param6];
    currentTimeParam.param7 = [self valueAtProgress:progress fromValue:beginParam.param7 toValue:endParam.param7];
    currentTimeParam.param8 = [self valueAtProgress:progress fromValue:beginParam.param8 toValue:endParam.param8];
    return currentTimeParam;
}

- (double)valueAtProgress:(double)progress fromValue:(double)fromValue toValue:(double)toValue {
    progress = MIN(1.0, progress);
    progress = MAX(0.0, progress);
    double retValue = fromValue + (toValue - fromValue) * progress;
    return retValue;
}

@end




