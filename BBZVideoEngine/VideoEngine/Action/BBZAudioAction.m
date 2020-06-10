//
//  BBZAudioAction.m
//  BBZVideoEngine
//
//  Created by bob on 2020/6/10.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZAudioAction.h"
@implementation BBZInputAudioParam
- (void)setSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if(sampleBuffer &&  _sampleBuffer == sampleBuffer) {
        return;
    }
    if(sampleBuffer) {
        CFRetain(sampleBuffer);
    }
    if(_sampleBuffer) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = nil;
    }
    _sampleBuffer = sampleBuffer;
}
@end


@implementation BBZAudioAction

- (BBZInputAudioParam *)inputAudioAtTime:(CMTime)time {
    return nil;
}

@end
