//
//  BBZVideoOutputFilter.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/11.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZMultiImageFilter.h"


@interface BBZVideoOutputFilter : BBZMultiImageFilter
@property (nonatomic, assign) CGSize outputVideoSize; // default 480x640
@property (nonatomic, assign) BOOL bShouldDrawAgain;//大多数情况下这里不需要再次draw了 直接写文件就好了

@end

