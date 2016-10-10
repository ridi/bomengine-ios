//
//  RBBomSelectable.m
//  Ridibooks
//
//  Created by Hyunwoo Nam on 2/16/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomSelectable.h"
#import "RBBomNodeInfo.h"

@implementation RBBomSelectable

- (id)initWithRect:(RBRectF)r nodeInfo:(RBBomNodeInfo *)node {
    self = [super init];
    if (self != nil) {
        _rect = r;
        _nodeInfo = node;
    }
    return self;
}

+ (RBBomSelectable *)selectableWithRect:(RBRectF)rect nodeInfo:(RBBomNodeInfo *)nodeInfo {
    return [[RBBomSelectable alloc] initWithRect:rect nodeInfo:nodeInfo];
}


@end
