//
//  BBZTransformSourceNode.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/28.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTransformSourceNode.h"
//#import "BBZShader.h"

@interface BBZTransformSourceNode ()
@property (nonatomic, strong) NSString *vertexShader;
@property (nonatomic, strong) NSString *fragmentShader;
@end

@implementation BBZTransformSourceNode
//- (instancetype)initWithYUVShader:(BOOL)bUseLastFB {
//    if(self = [super init]) {
//        if(bUseLastFB) {
//            _vertexShader = [BBZShader vertextTransfromShader];
//            _fragmentShader = [BBZShader fragmentFBFectchYUV420FTransfromShader];
//        } else {
//            _vertexShader = [BBZShader vertextTransfromShader];
//            _fragmentShader = [BBZShader fragmentYUV420FTransfromShader];
//        }
//        self.name = @"transfrom";
//    }
//    return self;
//}
//- (instancetype)initWithRGBShader:(BOOL)bUseLastFB {
//    if (self = [super init]) {
//        if(bUseLastFB) {
//            _vertexShader = [BBZShader vertextTransfromShader];
//            _fragmentShader = [BBZShader fragmentFBFectchRGBTransfromShader];
//        } else {
//            _vertexShader = [BBZShader vertextTransfromShader];
//            _fragmentShader = [BBZShader fragmentRGBTransfromShader];
//        }
//        self.name = @"transfrom";
//    }
//    return self;
//}

- (instancetype)init {
    if(self = [super init]) {
        self.name = @"transfrom";
    }
    return self;
}


- (NSString *)vShaderString {
    return self.vertexShader;
}

- (NSString *)fShaderString {
    return self.fragmentShader;
}


@end
