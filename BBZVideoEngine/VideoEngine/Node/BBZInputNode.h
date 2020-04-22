//
//  BBZInputNode.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/23.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZNode.h"


/*
         <input index="2" playOrder="2" assetOrder="2" scale="0.5">
 */
@interface BBZInputNode : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger playOrder;
@property (nonatomic, assign) NSInteger assetOrder;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) NSArray<BBZNode *> *actions;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
