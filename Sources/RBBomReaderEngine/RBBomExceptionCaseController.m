//
//  RBBomExceptionCaseController.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo on 11. 3. 9..
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomExceptionCaseController.h"
#import "RBBomNodeManager.h"
#import "RBBomTagNode.h"

@implementation RBBomExceptionCaseController

+ (void)removeExceptionCase:(RBBomNodeManager *)nodeMgr {
    RBBomTagNode *node = (RBBomTagNode *)nodeMgr.rootNode;
    
    while (node != nil) {
        if ([self isTagNode:node]) {
            // 예외 케이스 1 처리
            [self removeReturnCharacterNodeBetweenTagNodes:node];
            
            // 예외 케이스 2 처리
            [self removePageTagAfterFullscreenImage:node];
        }
        
        node = (RBBomTagNode *)node.nextNode;
    }
}

// 케이스1 : 태그 노드 사이의 엔터(\n) 제거
+ (void)removeReturnCharacterNodeBetweenTagNodes:(RBBomTagNode *)node {
    RBBomTagNode *nextNode = (RBBomTagNode *)node.nextNode;
    if (nextNode == nil)
        return;
    
    RBBomTagNode *nextOfNextNode = (RBBomTagNode *)nextNode.nextNode;
    if (nextOfNextNode == nil)
        return;
    
    // 풀스크린이 아닌 경우는 처리하지 않음
    if ([nextOfNextNode tagType] == RBBomNodeTagImg && [nextOfNextNode boolAttribute:@"fullscreen" defaultValue:NO] == NO) {
        return;
    }
    
    if ([self isReturnCharacterNode:nextNode] && [self isTagNode:nextOfNextNode]) {
        [self removeNextNode:node];
    }
}

// 케이스2 : PAGE 태그 or IMG 태그가 fullScreen 속성을 가지고 있고 바로 다음에 PAGE태그가 올 경우 PAGE 태그 제거
+ (void)removePageTagAfterFullscreenImage:(RBBomTagNode *)node {
    RBBomTagNode *nextNode = (RBBomTagNode *)node.nextNode;
    if (nextNode == nil)
        return;
    
    if ([self isTagToFillWholePage:node] && nextNode.tagType == RBBomNodeTagPage) {
        [self removeNextNode:node];
    }
}

// node 다음 노드를 제거하고 node의 nextNode를 다다음 node로 연결시킴
+ (void)removeNextNode:(RBBomTagNode *)node {
    RBBomTagNode *nextNode = (RBBomTagNode *)node.nextNode;
    RBBomTagNode *nextOfNextNode = (RBBomTagNode *)nextNode.nextNode;
    
    node.nextNode = nextOfNextNode;
    
    if (nextNode.parent == nil)
        [nextNode.parent removeChild:nextNode];
    
    nextNode = nil;
}

+ (BOOL)isReturnCharacterNode:(RBBomTagNode *)node {
    // TEXT 노드만 취급
    if (node == nil || [self isTagNode:node])
        return false;
    
    NSString *innerText = node.innerText;
    
    return [innerText length] == 1 && [innerText characterAtIndex:0] == '\n';
}

+ (BOOL)isTagToFillWholePage:(RBBomTagNode *)node {
    if (node.tagType == RBBomNodeTagPage)
        return YES;
    
    return node.tagType == RBBomNodeTagImg && [node boolAttribute:@"fullscreen" defaultValue:NO];
}

+ (BOOL)isTagNode:(RBBomTagNode *)node {
    return node != nil && node.tagType != RBBomNodeTagText;
}

@end
