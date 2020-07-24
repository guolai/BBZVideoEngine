//
//  BBZFilterMixer.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterMixer.h"
#import "BBZShader.h"
#import "BBZNode.h"

@interface BBZFilterMixer ()
@property (nonatomic, strong, readwrite) NSString *vShaderString;
@property (nonatomic, strong, readwrite) NSString *fShaderString;
@end


@implementation BBZFilterMixer


- (instancetype)initWithNodes:(NSArray *)nodes {
    if(self = [super init]) {
        self.vShaderString = [BBZFilterMixer vertexShaderFromNodes:nodes];
        self.fShaderString = [BBZFilterMixer fragmentShaderFromNodes:nodes];
    }
    return self;
}

+ (BBZFilterMixer *)filterMixerWithNodes:(NSArray *)nodes {
    BBZFilterMixer *filterMixer = [[BBZFilterMixer alloc] initWithNodes:nodes];
    return filterMixer;
}


#pragma mark - Private
+ (NSString *)vertexShaderFromNodes:(NSArray *)nodes {
    
    BBZNode *node = nodes.firstObject;
    NSString *vShader = node.vShaderString;
    if(!vShader) {
        vShader = [BBZShader vertextShader];
    }
    return vShader;
}

+ (NSString *)fragmentShaderFromNodes:(NSArray *)nodes {
    
    BBZNode *node = nodes.firstObject;
    NSString *fShader = node.fShaderString;
    if(!fShader) {
        if([node.name isEqualToString:BBZFilterBlendImage]) {
            fShader = [BBZShader fragmentMaskBlendShader];
        } else if([node.name isEqualToString:BBZFilterBlendVideo]) {
            fShader = [BBZShader fragmentMaskBlendShader];
        } 
    }
    
    if(!fShader) {
        fShader = [BBZShader fragmentPassthroughShader];
    }
    return fShader;
}

@end
