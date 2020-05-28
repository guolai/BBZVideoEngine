//
//  BBZFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterAction.h"
#import "BBZMultiImageFilter.h"

@interface BBZFilterAction ()
@property (nonatomic, strong) BBZMultiImageFilter *multiFilter;
@property (nonatomic, strong) NSMutableArray *arrayNode;
@end    

@implementation BBZFilterAction

- (instancetype)initWithNode:(BBZNode *)node {
    if(self = [super initWithNode:node]) {
        [self createImageFilter];
    }
    return self;
}

+ (BBZFilterAction *)createWithVistualAction:(BBZVistualFilterAction *)vistualAction {
    if(vistualAction.filterAction) {
        return vistualAction.filterAction;
    }
    BBZFilterAction *fitlerAction = [[BBZFilterAction alloc] initWithNode:vistualAction.node];
    fitlerAction.repeatCount = vistualAction.repeatCount;
    fitlerAction.startTime = vistualAction.startTime;
    fitlerAction.duration = vistualAction.duration;
//    fitlerAction.node =
    return fitlerAction;
}

- (void) addVistualAction:(BBZVistualFilterAction *)vistualAction {
    [self.arrayNode addObject:vistualAction.node];
}


- (BBZNode *)node {
    NSAssert(false, @"BBZFilterAction no node");
    return nil;
}



- (void)createImageFilter {
    self.multiFilter = [[BBZMultiImageFilter alloc] initWithVertexShaderFromString:self.node.vShaderString fragmentShaderFromString:self.node.fShaderString];
}

- (void)removeConnects {
    [self.multiFilter removeAllTargets];
}

- (id)filter {
    return self.multiFilter;
}


- (void)connectToAction:(id<BBZActionChainProtocol>)toAction {
    [self.multiFilter addTarget:[toAction filter]];
}


@end
