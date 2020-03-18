//
//  RBBomNode.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBBomNode : NSObject

@property (nonatomic) NSInteger nodeIndex;
@property (nonatomic, weak) RBBomNode *parent;
@property (nonatomic, weak) RBBomNode *nextNode;

- (BOOL)addChild:(RBBomNode *)node;
- (BOOL)removeChild:(RBBomNode *)node;
- (RBBomNode *)nodeAtIndex:(NSInteger)index;

- (BOOL)hasChild;
- (NSInteger)numberOfChildren;

@end
