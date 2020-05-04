//
//  BBZSourceAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//


#import "BBZAction.h"
#import "BBZBaseAsset.h"
#import "GPUImageFramebuffer.h"


@interface BBZSourceAction : BBZAction

@property (nonatomic, strong) BBZBaseAsset *asset;
@property (nonatomic, assign) CGSize renderSize;
@property (nonatomic, assign) CGFloat scale;


@end


