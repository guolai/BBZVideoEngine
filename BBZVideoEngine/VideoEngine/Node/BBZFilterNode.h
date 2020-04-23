//
//  BBZFilterNode.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/22.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZNode.h"


/*
 1.片头
 2.整体一直存在 根据片长循环
 3.某段时间存在 设定区间运行一次或者不到一次时长
 4.最后一段才出现 片尾
 
 timestamp 相对时间
 <filter index="0" timestamp="0.00"  duration="100.0" repeat="1">
 */
@interface BBZFilterNode : NSObject
@property (nonatomic, assign) CGFloat timestamp;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger repeat;
@property (nonatomic, strong) NSArray<BBZNode *> *actions;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
