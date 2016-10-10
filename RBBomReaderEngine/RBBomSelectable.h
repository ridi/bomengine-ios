//
//  RBBomSelectable.h
//  Ridibooks
//
//  Created by Hyunwoo Nam on 2/16/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomUtil.h"

@class RBBomNodeInfo;

@interface RBBomSelectable : NSObject

@property (nonatomic, readonly) RBRectF rect;
@property (nonatomic, readonly) RBBomNodeInfo *nodeInfo;

- (id)initWithRect:(RBRectF)rect nodeInfo:(RBBomNodeInfo *)nodeInfo;

+ (RBBomSelectable *)selectableWithRect:(RBRectF)rect nodeInfo:(RBBomNodeInfo *)nodeInfo;

@end
