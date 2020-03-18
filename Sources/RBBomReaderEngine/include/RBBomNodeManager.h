//
//  RBBomNodeManager.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 3/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBBomNode;
@class RBBomNodeRange;
@class RBBomNodeInfo;

@interface RBBomNodeManager : NSObject

@property (nonatomic, strong) RBBomNode *rootNode;

- (id)initWithRootNode:(RBBomNode *)rootNode;

- (RBBomNode *)nodeAtIndex:(NSInteger)nodeIndex;
- (BOOL)hasChildAtRootNode;

- (RBBomNodeInfo *)convertRawOffsetToNodeInfo:(NSInteger)rawOffset;

- (RBBomNodeRange *)wordNodeRangeAt:(RBBomNodeInfo *)nodeinfo;
- (NSString *)textInRange:(RBBomNodeRange *)range;

@end
