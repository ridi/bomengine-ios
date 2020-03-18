//
//  RBBomNodeInfo.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomNodeInfo.h"
#import "RBBomTagNode.h"

@implementation RBBomNodeInfo

- (id)initWithIndex:(NSInteger)index offset:(NSInteger)offset rawOffset:(NSInteger)rawOffset {
    if ((self = [super init])) {
        _nodeIndex = index;
        _offset = offset;
        _rawOffset = rawOffset;
    }
    return self;
}

+ (id)nodeInfoWithIndex:(NSInteger)index offset:(NSInteger)offset rawOffset:(NSInteger)rawOffset {
    return [[RBBomNodeInfo alloc] initWithIndex:index offset:offset rawOffset:rawOffset];
}

+ (id)nodeInfoWithTagNode:(RBBomTagNode *)tagNode {
    return [[RBBomNodeInfo alloc] initWithIndex:tagNode.nodeIndex offset:0 rawOffset:tagNode.rawOffset];
}

+ (id)nodeInfoWithNodeInfo:(RBBomNodeInfo *)baseNodeInfo {
    return [[RBBomNodeInfo alloc] initWithIndex:baseNodeInfo.nodeIndex offset:baseNodeInfo.offset rawOffset:baseNodeInfo.rawOffset];
}

+ (void)load {
    [NSKeyedUnarchiver setClass:[self class] forClassName:@"RBNodeInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        _nodeIndex = [aDecoder decodeIntegerForKey:@"nodeIndex"];
        _offset = [aDecoder decodeIntegerForKey:@"offset"];
        _rawOffset = [aDecoder decodeIntegerForKey:@"rawOffset"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_nodeIndex forKey:@"nodeIndex"];
    [aCoder encodeInteger:_offset forKey:@"offset"];
    [aCoder encodeInteger:_rawOffset forKey:@"rawOffset"];
}

- (NSComparisonResult)compareTo:(id<RBBomLocation>)location {
    if (_rawOffset < [location rawOffset]) {
        return NSOrderedAscending;
    }
    else if (_rawOffset > [location rawOffset]) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (void)moveOffset:(NSInteger)delta {
    _offset += delta;
    _rawOffset += delta;
}

@end
