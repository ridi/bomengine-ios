//
//  RBBomNodeRange.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 2/16/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomNodeRange.h"
#import "RBBomNodeInfo.h"

@implementation RBBomNodeRange

- (id)initWithStart:(RBBomNodeInfo *)start end:(RBBomNodeInfo *)end {
    self = [super init];
    if (self != nil) {
        _startRawOffset = start.rawOffset;
        _endRawOffset = end.rawOffset;
    }
    return self;
}

- (id)initWithStartPos:(NSInteger)start endPos:(NSInteger)end {
    self = [super init];
    if (self != nil) {
        _startRawOffset = start;
        _endRawOffset = end;
    }
    return self;
}

+ (id)nodeRangeWithStart:(RBBomNodeInfo *)start end:(RBBomNodeInfo *)end {
    return [[RBBomNodeRange alloc] initWithStart:start end:end];
}

+ (id)nodeRangeWithStartPos:(NSInteger)startPos endPos:(NSInteger)endPos {
    return [[RBBomNodeRange alloc] initWithStartPos:startPos endPos:endPos];
}

+ (void)load {
    [NSKeyedUnarchiver setClass:[self class] forClassName:@"RBNodeRange"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        RBBomNodeInfo *startNodeInfo = [aDecoder decodeObjectForKey:@"startNodeInfo"];
        if (startNodeInfo == nil)
            _startRawOffset = [aDecoder decodeIntForKey:@"startRawOffset"];
        else
            _startRawOffset = startNodeInfo.rawOffset;
        
        RBBomNodeInfo *endNodeInfo = [aDecoder decodeObjectForKey:@"endNodeInfo"];
        if (endNodeInfo == nil)
            _endRawOffset = [aDecoder decodeIntForKey:@"endRawOffset"];
        else
            _endRawOffset = endNodeInfo.rawOffset;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_startRawOffset forKey:@"startRawOffset"];
    [aCoder encodeInteger:_endRawOffset forKey:@"endRawOffset"];
}

- (RBBomRawLocation *)startLocation {
    return [RBBomRawLocation rawLocationWithOffset:self.startRawOffset];
}

- (RBBomRawLocation *)endLocation {
    return [RBBomRawLocation rawLocationWithOffset:self.endRawOffset];
}

- (BOOL)contains:(RBBomNodeInfo *)nodeInfo {
    return (self.startRawOffset <= nodeInfo.rawOffset &&
            nodeInfo.rawOffset <= self.endRawOffset);
}

@end
