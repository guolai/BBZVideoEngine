//
//  BBZFilterAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVistualFilterAction.h"
//#import "BBZMultiImageFilter.h"

@interface BBZFilterAction : BBZAction <BBZActionChainProtocol>

@property (nonatomic, assign) CGSize renderSize;

+ (BBZFilterAction *)createWithVistualAction:(BBZVistualFilterAction *)vistualAction;

- (void)addVistualAction:(BBZVistualFilterAction *)vistualAction;
- (void)addVistualNode:(BBZNode *)otherNode;

- (void)createImageFilter;

@end

