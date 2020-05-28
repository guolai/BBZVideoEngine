//
//  BBZNode.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZNode.h"
#import "NSDictionary+YYAdd.h"

@implementation BBZNodeAnimationParams

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if(self = [super init]) {
        self.param1 = [dic floatValueForKey:@"param1" default:0.0];
        self.param2 = [dic floatValueForKey:@"param2" default:0.0];
        self.param3 = [dic floatValueForKey:@"param3" default:0.0];
        self.param4 = [dic floatValueForKey:@"param4" default:0.0];
        self.param5 = [dic floatValueForKey:@"param5" default:0.0];
        self.param6 = [dic floatValueForKey:@"param6" default:0.0];
        self.param7 = [dic floatValueForKey:@"param7" default:0.0];
        self.param8 = [dic floatValueForKey:@"param8" default:0.0];
    }
    return self;
}

@end

@implementation BBZNodeAnimation

-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.begin = [dic floatValueForKey:@"begin" default:0.0];
        self.end = [dic floatValueForKey:@"end" default:0.0];
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
        self.begin = [dic floatValueForKey:@"begin" default:0.0];
        self.end = [dic floatValueForKey:@"end" default:3600.0];
        self.order = [dic intValueForKey:@"order" default:0];
        self.name = [dic stringValueForKey:@"name" default:nil];
        self.fShader = [dic stringValueForKey:@"fShader" default:nil];
        self.vShader = [dic stringValueForKey:@"vShader" default:nil];
        self.scale_mode = [dic stringValueForKey:@"scale_mode" default:nil];
        self.repeat = [dic intValueForKey:@"repeat" default:1];
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
        NSLog(@"Error: loading shader file:%@  %@",shaderFilePath, error.localizedDescription);
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
        NSLog(@"Error: loading shader file:%@  %@",shaderFilePath, error.localizedDescription);
        return nil;
    }
    return shaderString;
}


@end




