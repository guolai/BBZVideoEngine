//
//  BBZVistualFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVistualFilterAction.h"
#import "BBZFilterAction.h"

@implementation BBZVistualFilterAction


- (void)destroySomething {
    self.filterAction = nil;
}

- (void)removeConnects {
    [self.filterAction removeConnects];
}

@end
