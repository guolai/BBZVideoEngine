//
//  BBZTransitionGroupNode.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/24.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZInputNode.h"
/*
<inputGroup duration="2.00" order="1">
<input index="0">
<action begin="0.0" end="2.0" name="scale" order="1">
<animation begin="0.0" end="2.0">
<param_begin param1="1.15"/>
<param_end   param1="1.0"/>
</animation>
</action>
</input>
<input index="1">
<action begin="0.0" end="2.0" name="scale" order="1">
<animation begin="0.0" end="2.0">
<param_begin param1="1.15"/>
<param_end   param1="1.0"/>
</animation>
</action>
</input>
<transition timestamp="0.00" duration="0.3" repeat="1" order="2">
<action begin="0.000" end="0.3" name="image" fShader="heichang.glsl">
<animation begin="0.0" end="0.13">
<param_begin param1="1.0" param2="0" param3="0.0"/>
<param_end   param1="0.0" param2="0" param3="0.0"/>
</animation>
<animation begin="0.13" end="0.17">
<param_begin param1="0.0" param2="1" param3="0.0"/>
<param_end   param1="0.0" param2="1" param3="0.0"/>
</animation>
<animation begin="0.17" end="0.30">
<param_begin param1="0.0" param2="0" param3="0.0"/>
<param_end   param1="0.0" param2="0" param3="1.0"/>
</animation>
</action>
</transition>
 */

@interface BBZTransitionNode : NSObject
@property (nonatomic, assign) double timestamp;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) NSInteger repeat;
@property (nonatomic, strong) NSArray<BBZNode *> *actions;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end


@interface BBZTransitionGroupNode : NSObject
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, strong) NSArray<BBZInputNode *> *inputNodes;
@property (nonatomic, strong) BBZTransitionNode *transitionNode;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
