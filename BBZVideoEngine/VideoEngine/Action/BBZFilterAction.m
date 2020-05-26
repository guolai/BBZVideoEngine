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

- (instancetype)init {
    if(self = [super init]) {
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
    self.multiFilter = [[BBZMultiImageFilter alloc] init];
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
