//
//  RBBomNodeInfo.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomLocation.h"

@class RBBomTagNode;

@interface RBBomNodeInfo : NSObject <RBBomLocation, NSCoding>

@property (nonatomic, readonly) NSInteger nodeIndex;
@property (nonatomic) NSInteger offset;
@property (nonatomic) NSInteger rawOffset;

- (id)initWithIndex:(NSInteger)index offset:(NSInteger)offset rawOffset:(NSInteger)rawOffset;

+ (id)nodeInfoWithIndex:(NSInteger)index offset:(NSInteger)offset rawOffset:(NSInteger)rawOffset;
+ (id)nodeInfoWithTagNode:(RBBomTagNode *)tagNode;
+ (id)nodeInfoWithNodeInfo:(RBBomNodeInfo *)baseNodeInfo;

- (void)moveOffset:(NSInteger)delta;

@end
