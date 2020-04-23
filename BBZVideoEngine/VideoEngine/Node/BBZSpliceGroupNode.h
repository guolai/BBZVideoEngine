//
//  BBZSpliceGroupNode.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/24.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZInputNode.h"
/*
//<inputGroup duration="2.00" order="0">
//<input index="0" playOrder="0" assetOrder="0" scale="0.5">
//<action begin="0.0" end="2.0" name="fit_screen" scale_mode="AspectFit" order="1"/>
//</input>
//<input index="1" playOrder="1" assetOrder="1" scale="0.5">
//<action begin="0.0" end="2.0" name="fit_screen" scale_mode="AspectFit" order="2"/>
//</input>
//<input index="2" playOrder="2" assetOrder="2" scale="0.5">
//<action begin="0.0" end="2.0" name="fit_screen" scale_mode="AspectFit" order="3"/>
//</input>
//<input index="3" playOrder="3" assetOrder="3" scale="0.5">
//<action begin="0.0" end="2.0" name="fit_screen" scale_mode="AspectFit" order="4"/>
//</input>
//<splice >
//<action begin="0.0" end="2.0" name="four_input" fShader="four.glsl" order="1"/>
//</splice>
//</inputGroup>
*/

@interface BBZSpliceNode : NSObject
@property (nonatomic, strong) NSArray<BBZNode *> *actions;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

@interface BBZSpliceGroupNode : NSObject
@property (nonatomic, strong) NSArray<BBZInputNode *> *inputNodes;
@property (nonatomic, strong) BBZSpliceNode *spliceNode;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
