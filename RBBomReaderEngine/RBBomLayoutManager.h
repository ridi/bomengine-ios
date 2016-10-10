//
//  RBBomLayoutManager.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomNodeInfo.h"

typedef enum {
    RBBomLayoutPurposeRendering,
    RBBomLayoutPurposePaging,
} RBBomLayoutPurpose;

@class RBBomNodeManager;
@protocol RBBomRenderer;

@interface RBBomLayoutManager : NSObject

@property (nonatomic, weak) RBBomNodeManager *nodeMgr;
@property (nonatomic, strong) id<RBBomRenderer> renderer;
@property (nonatomic) RBBomLayoutPurpose purpose;

- (RBBomNodeInfo *)layoutPage:(RBBomNodeInfo *)from;
- (void)restoreContext:(RBBomNodeInfo *)from;

@end
