//
//  BBZCompositonDirector.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZCompositonDirector.h"

@implementation BBZCompositonDirector

#pragma mark - Schedule

- (void)updateWithTime:(CMTime)time{
    //to do check time 是否超出
}

- (void)didSeekToTime:(CMTime)time{
    
}

- (void)didReachEndTime{
    //到达结束两种情形 1.updateWithTime 2.读取资源失败并且接近尾声，
    //读取资源失败未接近尾声的时候可以通过纠错的方式来修正，比如返回一个黑帧或者返回上一帧画面(视频画面拉长或者视频将播放时长大于媒体时长，但是在action正常时常范围内)
}




@end
