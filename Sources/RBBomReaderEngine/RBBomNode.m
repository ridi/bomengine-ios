//
//  RBBomNode.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomNode.h"

@implementation RBBomNode {
    NSMutableArray *children;
}


- (id)init {
    if ((self = [super init])) {
        children = [[NSMutableArray alloc] init];
    }
    return self;
}


- (BOOL)addChild:(RBBomNode *)node {
    if (node == nil)
        return NO;
    
    node.parent = self;
    
    [children addObject:node];
    
    return YES;
}

- (BOOL)removeChild:(RBBomNode *)node {
    [children removeObject:node];
    return YES;
}

- (RBBomNode *)nodeAtIndex:(NSInteger)index {
    RBBomNode *node = self;
    
    while (node != nil) {
        if (node.nodeIndex == index)
            return node;
        
        node = [node nextNode];
    }
    
    return nil;
}

- (BOOL)hasChild {
    return [children count] > 0;
}

- (NSInteger)numberOfChildren {
    return [children count];
}

@end
