//
//  RBBomNodeRange.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 2/16/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

@protocol RBBomLocation;
@class RBBomNodeInfo;

@interface RBBomNodeRange : NSObject <NSCoding>

@property (nonatomic, readonly) NSInteger startRawOffset;
@property (nonatomic, readonly) NSInteger endRawOffset;

- (id)initWithStart:(RBBomNodeInfo *)start end:(RBBomNodeInfo *)end;
- (id)initWithStartPos:(NSInteger)startPos endPos:(NSInteger)endPos;
+ (id)nodeRangeWithStart:(RBBomNodeInfo *)start end:(RBBomNodeInfo *)end;
+ (id)nodeRangeWithStartPos:(NSInteger)startPos endPos:(NSInteger)endPos;

- (BOOL)contains:(RBBomNodeInfo *)nodeInfo;

@end
