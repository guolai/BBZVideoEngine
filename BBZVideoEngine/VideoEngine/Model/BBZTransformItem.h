//
//  BBZTransformItem.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/6/15.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZVideoEngineHeader.h"

@interface BBZTransformItem : NSObject
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat tx;
@property (nonatomic, assign) CGFloat ty;
@property (nonatomic, assign) CGFloat angle;

@end
