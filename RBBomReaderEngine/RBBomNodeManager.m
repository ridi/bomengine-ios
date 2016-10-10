//
//  RBBomNodeManager.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 3/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomNodeManager.h"
#import "RBBomNodeInfo.h"
#import "RBBomNodeRange.h"
#import "RBBomTagNode.h"
#import "RBBomStringBuilder.h"

@implementation RBBomNodeManager

- (id)initWithRootNode:(RBBomNode *)node {
    self = [super init];
    if (self != nil) {
        _rootNode = node;
    }
    return self;
}


- (RBBomNode *)nodeAtIndex:(NSInteger)nodeIndex {
    return [_rootNode nodeAtIndex:nodeIndex];
}

- (BOOL)hasChildAtRootNode {
    return [_rootNode hasChild];
}

- (RBBomNodeInfo *)convertRawOffsetToNodeInfo:(NSInteger)rawOffset {
    RBBomTagNode *node = (RBBomTagNode *)_rootNode.nextNode;
    RBBomNodeInfo *location = [RBBomNodeInfo nodeInfoWithIndex:node.nodeIndex offset:rawOffset - node.rawOffset rawOffset:rawOffset];
    
    while (node != nil) {
        if (node.rawOffset > rawOffset) {
            break;
        }   
        
        RBBomTagNode *lastNode = node;
        location = [RBBomNodeInfo nodeInfoWithIndex:lastNode.nodeIndex offset:rawOffset - lastNode.rawOffset rawOffset:rawOffset];
        node = (RBBomTagNode *)node.nextNode;
    }
    
    return location;
}

- (RBBomNodeRange *)wordNodeRangeAt:(RBBomNodeInfo *)nodeinfo {
    RBBomNodeInfo *startNodeInfo = [RBBomNodeInfo nodeInfoWithNodeInfo:nodeinfo];
    RBBomNodeInfo *endNodeInfo = [RBBomNodeInfo nodeInfoWithNodeInfo:nodeinfo];
    
    RBBomTagNode *node = (RBBomTagNode *)[_rootNode nodeAtIndex:nodeinfo.nodeIndex];
    NSString *innerText = node.innerText;
    NSInteger index;
    
    // 앞 단어 찾기
    index = nodeinfo.offset;
    while (index > 0) {
        --index;
        if ([innerText characterAtIndex:index] == ' ' ||
            [innerText characterAtIndex:index] == '\n') {
            ++index;
            break;
        }
    }
    
    [startNodeInfo moveOffset:index - nodeinfo.offset];
    
    // 뒷 단어 찾기
    index = nodeinfo.offset;
    while (index < [innerText length] - 1) {
        ++index;
        if ([innerText characterAtIndex:index] == ' ' ||
            [innerText characterAtIndex:index] == '\n') {
            --index;
            break;
        }
    }
    
    [endNodeInfo moveOffset:index - nodeinfo.offset];
    
    return [RBBomNodeRange nodeRangeWithStart:startNodeInfo end:endNodeInfo];
}

- (NSString *)textInRange:(RBBomNodeRange *)range {
    if ([_rootNode numberOfChildren] == 0) {
        return nil;
    }
    
    RBBomStringBuilder *texts = [[RBBomStringBuilder alloc] init];
    
    RBBomNodeInfo *startNodeInfo = [self convertRawOffsetToNodeInfo:range.startRawOffset];
    RBBomNodeInfo *endNodeInfo = [self convertRawOffsetToNodeInfo:range.endRawOffset];
    
    RBBomTagNode *node = (RBBomTagNode *)[_rootNode nodeAtIndex:startNodeInfo.nodeIndex];
    
    while (node != nil) {
        if (node.nodeIndex > endNodeInfo.nodeIndex) {
            break;
        }
        
        if (node.innerText.length > 0) {
            if (node.nodeIndex == startNodeInfo.nodeIndex) {
                if (startNodeInfo.nodeIndex != endNodeInfo.nodeIndex) {
                    [texts appendString:[node.innerText substringFromIndex:startNodeInfo.offset]];
                }
                else {
                    NSRange range = NSMakeRange(startNodeInfo.offset, endNodeInfo.offset - startNodeInfo.offset + 1);
                    [texts appendString:[node.innerText substringWithRange:range]];
                }
            }
            else if (node.nodeIndex > startNodeInfo.nodeIndex &&
                       node.nodeIndex < endNodeInfo.nodeIndex) {
                [texts appendString:node.innerText];
            }
            else if (node.nodeIndex == endNodeInfo.nodeIndex) {
                [texts appendString:[node.innerText substringToIndex:endNodeInfo.offset + 1]];
            }
        }
        
        node = (RBBomTagNode *)node.nextNode;
    }
    
    return [texts toString];
}

@end
