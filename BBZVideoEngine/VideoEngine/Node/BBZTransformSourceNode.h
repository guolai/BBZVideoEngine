//
//  BBZTransformSourceNode.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/28.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZNode.h"


@interface BBZTransformSourceNode : BBZNode
- (instancetype)initWithYUVShader:(BOOL)bUseLastFB;
- (instancetype)initWithRGBShader:(BOOL)bUseLastFB;

@end

