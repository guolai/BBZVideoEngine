//
//  BBZFilterAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVistualFilterAction.h"
#import "BBZMultiImageFilter.h"

@interface BBZFilterAction : BBZVistualFilterAction
@property (nonatomic, strong) BBZMultiImageFilter *filter;
@end

