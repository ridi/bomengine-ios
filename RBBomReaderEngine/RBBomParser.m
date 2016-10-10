//
//  RBBomParser.m
//  RBBomReaderEngine
//
//  Created by Earus on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomParser.h"
#import "RBBomDataReader.h"
#import "RBBomTagNode.h"
#import "RBBomAttribute.h"
#import "RBBomStringBuilder.h"

typedef enum {
    CHARACTER_TYPE_TEXT,
    CHARACTER_TYPE_TAG
} RBCharacterType;

typedef enum {
    PARSE_ATTR_INVALID_FORMAT,
    PARSE_ATTR_END_OPNER,
    PARSE_ATTR_END_FINISHED,
    PARSE_ATTR_OK
} RBParseAttrResult;


@interface RBBomParser () {
    RBBomDataReader *reader;
    RBBomTagNode *workingNode;
    RBBomTagNode *lastAddedNode;
    NSInteger nodeIndex;
}

@end


@implementation RBBomParser

- (id)initWithReader:(RBBomDataReader *)aReader {
    if ((self = [super init])) {
        reader = aReader;

        _rootNode = [[RBBomTagNode alloc] initWithTag:RBBomNodeTagNothing rawOffset:0];
        _rootNode.tagStatus = RBBomTagStatusUnknown;
        _rootNode.nodeIndex = 0;
        workingNode = _rootNode;
        lastAddedNode = _rootNode;
        nodeIndex = 0;
    }
    return self;
}


- (void)parse {
    NSInteger lastOffset = 0;
    RBBomStringBuilder *parsedText = [[RBBomStringBuilder alloc] init];
    
    while ([reader isReadable]) {
        
        unichar ch = [reader getCurrPosChar];
        
        if ([self guessNextCharacterType:ch] == CHARACTER_TYPE_TAG) {
            // 태그가 아닐 경우 돌아갈 위치 기억
            [reader rememberCurrPos];
            
            // 태그 파싱
            RBBomTagNode *tagNode = [self parseTag];
            
            // null이 아니면 정상적인 태그 형식인 것으로 보면 됨
            if (tagNode != nil) {
                // 태그 정보를 추가 전에 이미 파싱된 텍스트가 있으면 TEXT 태그로 먼저 추가
                if ([parsedText length] > 0) {
                    RBBomTagNode *textNode = [self makeTextNode:[parsedText toString] lastOffset:lastOffset];
                    [self addToWorkingNode:textNode];
                    [parsedText clear];
                    
                    lastOffset = [reader getRememberedPos];
                }
                
                tagNode.rawOffset = lastOffset;
                [self procNodeWithWorkingNode:tagNode];
                
                lastOffset = reader.pos;
                continue;
                
            }
            else {
                // 제대로 된 형식의 태그가 아니기 때문에 원래 위치로 돌리고 { 는 일반 텍스트 형태로 더함
                [reader backToRememberedPos];
            }
        }
        
        [parsedText appendCharacter:ch];
        [reader goForward:1];
    }
    
    // 내용 끝까지 파싱이 끝난 후 남아있는 텍스트가 있으면 TEXT 태그로 만들어 추가
    if ([parsedText length] > 0) {
        RBBomTagNode *textNode = [self makeTextNode:[parsedText toString] lastOffset:lastOffset];
        [self addToWorkingNode:textNode];
    }
    
    workingNode = nil;
    lastAddedNode = nil;
    
    
    // 노드 찍어보기
    //[self printNodes:rootNode];
}

- (RBCharacterType)guessNextCharacterType:(unichar)c {
    switch (c) {
        case '{':
            return CHARACTER_TYPE_TAG;
            
        default:
            return CHARACTER_TYPE_TEXT;
    }
}

- (RBBomTagNode *)makeTextNode:(NSString *)text lastOffset:(NSInteger)offset {
    RBBomTagNode *textTagNode = [[RBBomTagNode alloc] initWithTag:RBBomNodeTagText rawOffset:offset];
    
    textTagNode.innerText = [NSString stringWithString:text];

    return textTagNode;
}

- (void)procNodeWithWorkingNode:(RBBomTagNode*)tagNode {
    [self addToWorkingNode:tagNode];
    
    if (tagNode.tagStatus == RBBomTagStatusOpener) {
        workingNode = tagNode;
    }
    else if (tagNode.tagStatus == RBBomTagStatusCloser) {
        RBBomTagNode *parentNode = (RBBomTagNode*)workingNode.parent;
        
        if (parentNode != nil && workingNode.tagType == tagNode.tagType) {
            workingNode = parentNode;
        }
    }
    else if (tagNode.tagStatus == RBBomTagStatusFinished) {
        // DO NOTHING
    }
}

- (void)addToWorkingNode:(RBBomTagNode*)tagNode {
    [tagNode setNodeIndex:++nodeIndex];
    [workingNode addChild:tagNode];

    lastAddedNode.nextNode = tagNode;
    lastAddedNode = tagNode;
}

- (RBBomTagNode *)parseTag {
    
    NSInteger tagBeginPos = reader.pos;
    
    BOOL closerTag = NO;
    
    // skip '{'
    // assert([reader getCurrPosChar] == '{');
    [reader goForward:1];
    
    // Closer 태그인지 확인
    if ([reader getCurrPosChar] == '/') {
        closerTag = YES;
        [reader goForward:1];
    }
    
    // 태그명 파싱
    NSString *tagName = [self parseTagName];
    RBBomNodeTag tagType = [RBBomTagNode tagTypeFromName:tagName];
    
    // Closer 태그인지 확인
    if ([reader getCurrPosChar] == '/') {
        closerTag = YES;
        [reader goForward:1];
    }
    
    if (tagType != RBBomNodeTagNothing) {
        // 맞는 태그명이면 태그노드 생성
        RBBomTagNode *tagNode = [[RBBomTagNode alloc] initWithTag:tagType rawOffset:tagBeginPos];
        
        if (!closerTag) {
            // 닫는 태그가 아니면 attribute 파싱
            if ([self parseAttributes:tagNode] == NO) {
                // 비정상적인 구문으로 되어있으면
                return nil;
            }
        }
        else {
            // 닫는 태그일 경우 처리 } 까지 읽음
            [reader readUntil:'}'];
            [reader goForward:1];
            
            [tagNode setTagStatus:RBBomTagStatusCloser];
        }
        
        return tagNode;
    }
    
    // 태그명에 해당하는게 아니면 태그가 아님
    return nil;
}

- (NSString *)parseTagName {
    return [reader getNextToken];
}

- (BOOL)parseAttributes:(RBBomTagNode*)tagNode {
    // attribute 이름 파싱
    NSMutableString *attrName = [[NSMutableString alloc] init];
    
    while ([reader isReadable]) {
        [attrName deleteCharactersInRange:NSMakeRange(0, [attrName length])];
        
        RBParseAttrResult ret = [self parseAttrName:tagNode nameBuffer:attrName];
        
        if (ret == PARSE_ATTR_INVALID_FORMAT) {
            return NO;
        }
        else if (ret == PARSE_ATTR_END_OPNER) {
            [tagNode setTagStatus:RBBomTagStatusOpener];
            return YES;
        }
        else if (ret == PARSE_ATTR_END_FINISHED) {
            [tagNode setTagStatus:RBBomTagStatusFinished];
            return YES;
        }
        
        if ([self parseValueSyntax] == NO) {
            // =" 가 안나오면 실패
            return NO;
        }
        
        // attribute 값 파싱
        NSString *attrValue = [self parseAttrValue];
        
        if (attrValue == nil) {
            // 내용 끝까지 가도 "가 안나오면
            return NO;
        }
        
        // 파싱된 attribute 한 개 추가
        RBBomAttribute *attr = [[RBBomAttribute alloc] initWithKey:[NSString stringWithString:attrName] value:attrValue];
        [tagNode addAttribute:attr];
    }
    
    return YES;
}

- (RBParseAttrResult)parseAttrName:(RBBomTagNode*)tagNode nameBuffer:(NSMutableString*)buffer {
    unichar ch;
    
    while ([reader isReadable]) {
        // 화이트 스페이스들은 모두 건너띄고 나오는 첫 문자
        ch = [reader getCharSkipWhite];
        
        if (ch == '{') {
            // 또 다른 {가 나오면 잘못된 태그
            return PARSE_ATTR_INVALID_FORMAT;
        }
        if (ch == '}') {
            // 그냥 태그가 닫히면 OPENER TAG
            // 하지만 FONT, LINK가 아니면 FINISH 된 것으로 처리함
            [tagNode setTagStatus:RBBomTagStatusOpener];
            return PARSE_ATTR_END_OPNER;
        }
        else if (ch == '/' && [reader getCharSkipWhite] == '}') {
            // /} 형태로 닫히면 FINISHED
            [tagNode setTagStatus:RBBomTagStatusFinished];
            return PARSE_ATTR_END_FINISHED;
        }
        
        // attribute name이 끝나고 = 가 나오면 끝
        if (ch == '=') {
            break;
        }
        
        [buffer appendString:[NSString stringWithFormat:@"%C", ch]];
    }
    
    return PARSE_ATTR_OK;
}

- (BOOL)parseValueSyntax {
    // 화이트 스페이스를 무시하고 "가 바로 나오는지 확인(attribute= 다음 부분 체크)
    if ([reader getCharSkipWhite] == '"') {
        return YES;
    }
    
    return NO;
}

- (NSString *)parseAttrValue {
    NSString *value = [reader readUntil:'"'];
    [reader goForward:1];
    
    return value;
}

- (void)printNodes:(RBBomTagNode*)tagNode {
    RBBomTagNode *node;
    
    node = (RBBomTagNode*) tagNode.nextNode;
    
    while(node != nil) {
        NSLog(@"index : %zd, rawoffset : %zd", node.nodeIndex, node.rawOffset);
        
        node = (RBBomTagNode*) node.nextNode;
    }
}

+ (NSString *)removeTag:(NSString *)plainText {
    
    RBBomStringBuilder *buffer = [[RBBomStringBuilder alloc] init];
    BOOL inTag = NO;
    BOOL firstClosure = YES;
    
    if (plainText == nil) {
        return nil;        
    }
    
    for (NSInteger i = 0; i < [plainText length]; i++) {
        if (inTag == NO && [plainText characterAtIndex:i] == '{')
            inTag = YES;
        
        if (inTag == NO)
            [buffer appendCharacter:[plainText characterAtIndex:i]];
        
        if ([plainText characterAtIndex:i] == '}') {
            if (inTag == NO && firstClosure == YES) {
                [buffer clear];
                firstClosure = NO;
            }
            
            inTag = NO;
        }
    }
    
    NSString *removedText = [buffer toString];
    
    return removedText;
}

@end
