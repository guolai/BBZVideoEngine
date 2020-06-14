//
//  BBZFilterMixer.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface BBZFilterMixer : NSObject
@property (nonatomic, strong, readonly) NSString *vShaderString;
@property (nonatomic, strong, readonly) NSString *fShaderString;

- (instancetype)initWithNodes:(NSArray *)nodes;
+ (BBZFilterMixer *)filterMixerWithNodes:(NSArray *)nodes;

@end


