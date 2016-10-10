//
//  RBBomLayoutManager.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomLayoutManager.h"
#import "RBBomTagNode.h"
#import "RBBomRendererContext.h"
#import "RBBomRenderer.h"
#import "RBBomStringBuilder.h"
#import "RBBomNodeManager.h"

@interface TextSegment : NSObject {
  @private
    NSString *segmentText;
    NSInteger offsetLengthToSkip;
    BOOL isWrapped;
}

+ (TextSegment *)textSegementWithText:(NSString *)segmentText offsetLegnthToSkip:(NSInteger)offset wrapped:(BOOL)wrapped;

@property (nonatomic, readonly) NSString *segmentText;
@property (nonatomic, readonly) NSInteger offsetLengthToSkip;
@property (nonatomic, readonly) BOOL isWrapped;

@end

@implementation TextSegment

@synthesize segmentText;
@synthesize offsetLengthToSkip;
@synthesize isWrapped;

- (id)initWithText:(NSString *)text offsetLegnthToSkip:(NSInteger)offset wrapped:(BOOL)wrapped {
    self = [super init];
    if (self != nil) {
        segmentText = text;
        offsetLengthToSkip = offset;
        isWrapped = wrapped;
    }
    return self;
}


+ (TextSegment *)textSegementWithText:(NSString *)segmentText offsetLegnthToSkip:(NSInteger)offset wrapped:(BOOL)wrapped {
    return [[TextSegment alloc] initWithText:segmentText offsetLegnthToSkip:offset wrapped:wrapped];
}

@end


static RBBomAlign getAlign(NSString *value, RBBomAlign defaultValue);
static BOOL isEndingSpecialChar(unichar ch);
static BOOL isSpecialChar(unichar ch);
static BOOL isAlphaOrNumber(unichar ch);


@implementation RBBomLayoutManager {
    RBBomRendererContext *currentContext;
    NSMutableArray *contextStack;
    
    float posX;
    float posY;
    NSInteger offset;
    float rowHeight;
}


- (id)init {
    if ((self = [super init])) {
        contextStack = [[NSMutableArray alloc] init];
        [self initContext];
        
        posX = posY = 0;
        offset = 0;
        
        _purpose = RBBomLayoutPurposeRendering;
    }
    return self;
}


- (void)initContext {
    [contextStack removeAllObjects];
    
    currentContext = [[RBBomRendererContext alloc] init];
    [contextStack addObject:currentContext];
}

- (void)restoreContext:(RBBomNodeInfo *)from {
    RBBomTagNode *node = (RBBomTagNode *)[_nodeMgr nodeAtIndex:from.nodeIndex].parent;
    NSMutableArray *family = [[NSMutableArray alloc] init];
    RBBomRendererContext *context;
    
    [self initContext];
    
    // node 순회
    while (node != nil) {
        // CLOSER 태그나 FINISHED된 태그들은 컨텍스트에 영향이 없으므로
        // OPENER만 컨텍스트에 반영
        switch (node.tagType) {
			case RBBomNodeTagFont:
			case RBBomNodeTagSup:
			case RBBomNodeTagSub:
				[family insertObject:node atIndex:0];
				break;
            default:
                break;
        }
        
        node = (RBBomTagNode *)node.parent;
    }
    
    for (NSInteger i = 0; i < [family count]; ++i) {
        node = [family objectAtIndex:i];
        
        if (node.tagStatus != RBBomTagStatusOpener)
            continue;
        
        switch (node.tagType) {
			case RBBomNodeTagFont:
				context = [self makeContextFromFontTagNode:node];
                [self pushContext:context];
				break;
				
			case RBBomNodeTagSup:
				context = [self makeContextFromSupTagNode:node];
                [self pushContext:context];
				break;
				
			case RBBomNodeTagSub:
				context = [self makeContextFromSubTagNode:node];
                [self pushContext:context];
				break;
                
            default:
                break;
        }
    }
    
    [self applyContext];
    
}

- (RBBomNodeInfo *)layoutPage:(RBBomNodeInfo *)from {
    [self initPosition];			// 좌표 초기화
    rowHeight = 0;
    
    if (_nodeMgr == nil) {
        return nil;
    }
    
    RBBomTagNode *node = (RBBomTagNode *)[_nodeMgr nodeAtIndex:from.nodeIndex];
    
    offset = from.offset;
    
    
    // node 순회
    while (node != nil) {
        // 닫는 태그이면 context POP하고 다음 노드 탐색
        if (node.tagStatus == RBBomTagStatusCloser) {
            [self popContext];
            node = (RBBomTagNode *)node.nextNode;
            offset = 0;
            continue;
        }
        
        RBBomNodeInfo *nextNode = nil;
        RBBomRendererContext *rendContext = nil;
        
        switch (node.tagType) {
        case RBBomNodeTagFont:
        {
            // 스타일 컨텍스트 적용
            rendContext = [self makeContextFromFontTagNode:node];
            [self pushContext:rendContext];
            break;
        }
            
        case RBBomNodeTagImg:
        {
            nextNode = [self layoutImage:node
                                nodeInfo:[RBBomNodeInfo nodeInfoWithIndex:node.nodeIndex offset:offset rawOffset:node.rawOffset + offset]
                         beginningOfPage:(node.nodeIndex == from.nodeIndex)];
            if (nextNode != nil)
                return nextNode;
            
            break;
        }
            
        case RBBomNodeTagPage:
        {
            // 페이지 종료시킴                
            if (node.nextNode == nil)
                return nil;
            
            return [RBBomNodeInfo nodeInfoWithTagNode:(RBBomTagNode *)node.nextNode];
        }
				
        case RBBomNodeTagText:
        {
            nextNode = [self layoutText:node
                               nodeInfo:[RBBomNodeInfo nodeInfoWithIndex:node.nodeIndex offset:offset rawOffset:node.rawOffset + offset]];
            if (nextNode != nil)
                return nextNode;
            break;
        }

        case RBBomNodeTagSup:
        {
            // 윗첨자
            rendContext = [self makeContextFromSupTagNode:node];
            [self pushContext:rendContext];
            break;
        }
            	
        case RBBomNodeTagSub:
        {
            // 아랫첨자
            rendContext = [self makeContextFromSubTagNode:node];
            [self pushContext:rendContext];
            break;
        }
                
        default:
            break;
        }
        
        node = (RBBomTagNode *)node.nextNode;
        offset = 0;
    }
    
    return nil;
}

- (RBBomNodeInfo *)layoutText:(RBBomTagNode *)node nodeInfo:(RBBomNodeInfo *)from {
    NSString *innerText = node.innerText;
    NSInteger textOffset = offset;
    
    while (textOffset < [innerText length]) {
        if (posY >= _renderer.canvasSize.height - _renderer.marginBottom - [_renderer getFontHeight]) {
            // 끝난 위치의 노드정보 전달
            offset = textOffset;
            
            return [RBBomNodeInfo nodeInfoWithIndex:node.nodeIndex offset:offset rawOffset:node.rawOffset + offset];
        }
        
        float segment_x = posX;
        float segment_y = posY;
        
        TextSegment *segment = [self layoutTextSegment:innerText textOffset:textOffset];
        
        if ([segment.segmentText length] == 0) {
            textOffset += segment.offsetLengthToSkip;
            continue;
        }
        
        RBPointF addPoint = [self applySubscriptPoint:RBPointFMake(segment_x, segment_y)];
        RBBomNodeInfo *addNodeInfo = [RBBomNodeInfo nodeInfoWithIndex:from.nodeIndex offset:textOffset rawOffset:node.rawOffset + textOffset];
        
        RBBomRendererContext *segmentContext;
        
        if (segment.isWrapped && currentContext.align == RBBomAlignLeft) {
            segmentContext = [self baseContextFromCurrentContext];
            segmentContext.wrapped = YES;
        }
        else {
            segmentContext = currentContext;
        }
        
        [self deliverAlignedTextRenderable:segmentContext
                                      text:segment.segmentText
                                         x:addPoint.x
                                         y:addPoint.y
                            measuredLength:[_renderer measureText:segment.segmentText]
                                  nodeInfo:addNodeInfo];
        
        textOffset += segment.offsetLengthToSkip;
    }
    
    offset = textOffset;
    
    return nil;
}

- (void)updateRowHeight:(float)height {
    if (rowHeight < height)
        rowHeight = height;
}

- (void)lineBreak {
    // line feed
    [self moveY:rowHeight];
    rowHeight = 0;
    
    // kelly return
    [self initPositionX];
}

static NSInteger wordWrap(RBBomStringBuilder *sb) {
    NSInteger index = [sb length] - 1;
    
    // 마지막이 구둣점으로 끝나면, 공백까지 자름.
    if (isEndingSpecialChar([sb characterAtIndex:index])) {
        --index;
        while (index >= 0 && (isAlphaOrNumber([sb characterAtIndex:index]) || isSpecialChar([sb characterAtIndex:index]))) {
            --index;
        }        
        return index;
    }
    
    if (index >= 0 && (isAlphaOrNumber([sb characterAtIndex:index]) || isSpecialChar([sb characterAtIndex:index]))) {
        // word wrap 모드
        --index;
        while (index >= 0 && (isAlphaOrNumber([sb characterAtIndex:index]) || isSpecialChar([sb characterAtIndex:index]))) {
            --index;
        }
        ++index;
    }
    
    return index;
}

- (TextSegment *)layoutTextSegment:(NSString *)innerText textOffset:(NSInteger)textOffset {
    
    RBBomStringBuilder *sb = [[RBBomStringBuilder alloc] init];
    float textWidth = posX - _renderer.marginLeft;
    NSInteger skipCharacterCount = 0;
    
    [self updateRowHeight:[_renderer getFontHeight] + _renderer.lineHeight];
    
    while (textOffset < [innerText length]) {
        
        unichar ch = [innerText characterAtIndex:textOffset++];
        
        if (ch == '\r') {
            // \r 무시
            ++skipCharacterCount;
            continue;
        }
        
        if (ch == '\n') {
            // 줄넘김이면
            [self lineBreak];
            [self updateRowHeight:[_renderer getFontHeight] + _renderer.lineHeight];
            
            ++skipCharacterCount;
            
            NSString *segmentText = [sb toString];
            
            return [TextSegment textSegementWithText:segmentText offsetLegnthToSkip:[segmentText length] + skipCharacterCount wrapped:NO];
        }
        
        [sb appendCharacter:ch];
        textWidth += [_renderer measureChar:ch];
        
        // 한 줄 넘어가면
        if (textWidth > _renderer.contentWidth) {
            NSInteger index = wordWrap(sb);
            
            if (index > 0) {
                // wrapped된 단어가 화면에 들어가는 길이면
                [sb deleteCharactersFromIndex:index];
                
                // 양쪽 정렬 상태에서 맨 오른쪽 단어가 공백이면 트리밍
                if ([sb characterAtIndex:[sb length] - 1] == ' ') {
                    [sb deleteLastCharacter];
                    skipCharacterCount++;
                }
            }
            else {
                // wrapped된 단어가 content width 보다 길면
                [sb deleteCharactersFromIndex:[sb length] - 1];
            }
            
            // 다음줄의 시작(넣어서 넘친 문자)이 스페이스는 노노
            if (ch == ' ') {
                skipCharacterCount++;
            }
            
            [self lineBreak];
            [self updateRowHeight:[_renderer getFontHeight] + _renderer.lineHeight];
            
            NSString *segmentText = [sb toString];
            return [TextSegment textSegementWithText:segmentText offsetLegnthToSkip:[segmentText length] + skipCharacterCount wrapped:YES];
        }
    }
    
    // while 다 돌고 버퍼에 남아있는 텍스트 있으면 렌더러블 추가
    if ([sb length] > 0) {
        NSString *text = [sb toString];
        float bufWidth = [_renderer measureText:text];
        [self moveX:bufWidth];
    }
    
    NSString *segmentText = [sb toString];
    
    [self updateRowHeight:[_renderer getFontHeight] + _renderer.lineHeight];
    
    return [TextSegment textSegementWithText:segmentText offsetLegnthToSkip:[segmentText length] + skipCharacterCount wrapped:NO];
}

- (void)deliverAlignedTextRenderable:(RBBomRendererContext *)context text:(NSString *)text x:(float)x y:(float)y measuredLength:(float)measuredLength nodeInfo:(RBBomNodeInfo *)nodeInfo {
    float text_x = x;
    
    switch (context.align) {
        case RBBomAlignLeft:
            text_x = x;
            break;
            
        case RBBomAlignCenter:
            text_x = (_renderer.canvasSize.width - measuredLength) / 2;
            break;
            
        case RBBomAlignRight:
            text_x = _renderer.canvasSize.width - _renderer.marginRight - measuredLength;
            break;
    }
    
    [_renderer deliverTextRenderable:context text:text x:text_x y:y nodeInfo:nodeInfo];
}

- (RBBomNodeInfo *)layoutImage:(RBBomTagNode *)node nodeInfo:(RBBomNodeInfo *)from beginningOfPage:(BOOL)beginningOfPage {
    NSString *imgSrc = [node stringAttribute:@"src"];
    NSString *imgCaption = [node stringAttribute:@"caption"];
    NSInteger imgAlign = getAlign([node stringAttribute:@"align"], RBBomAlignCenter);
    NSInteger imgWidth = [node integerAttribute:@"width" defaultValue:-1];
    NSInteger imgHeight = [node integerAttribute:@"height" defaultValue:-1];
    BOOL imgFullscreen = [node boolAttribute:@"fullscreen" defaultValue:NO];
    //boolean imgZoom = node.getBooleanAttr("zoom", false);
    //boolean imgFloat = node.getBooleanAttr("float", false);
    
    
    if (imgSrc == nil) {
        // 이미지 경로 데이터가 없으면
        return nil;
    }
    
    // 태그에 이미지 크기가 없을 경우
    if (imgWidth == -1 || imgHeight == -1) {
        // performance trick
        if (_purpose == RBBomLayoutPurposePaging && imgFullscreen) {
            imgWidth = 1;
            imgHeight = 1;
        }
        else {
            RBSizeF imgSize;
            if ([_renderer getImageSize:imgSrc size:&imgSize] == NO)
                return nil;
            
            imgWidth = (NSInteger) imgSize.width;
            imgHeight = (NSInteger) imgSize.height;
        }
    }
    
    
    float captionWidth = 0;
    float captionHeight = 0;
    
    // 캡션 전처리
    if (imgCaption != nil) {
        // 캡션이 추가될 공간 계산
        captionHeight = _renderer.lineHeight / 2 + [_renderer getFontHeight];
        
        for (NSInteger i = 0; i < [imgCaption length]; i++) {
            captionWidth = [_renderer measureText:[imgCaption substringToIndex:i + 1]];
            
            if (captionWidth > _renderer.contentWidth) {
                // 캡션이 Content 가로넓이를 넘어가면 ... 으로 처리
                if ([imgCaption length] > 3) {
                    imgCaption = [[imgCaption substringToIndex:i - 1] stringByAppendingString:@"..."];
                    break;
                }
            }
        }
    }
    
    // 풀스크린일 경우
    if (imgFullscreen) {
        if (beginningOfPage) {
            RBSizeF contentSize = RBSizeFMake(_renderer.contentWidth, _renderer.contentHeight - captionHeight);
            float display_height = contentSize.height;
            
            const RBSizeF actualSize = RBSizeFMake(imgWidth, imgHeight);
            RBSizeF scaledSize = RBSizeFMake(imgWidth, imgHeight);
            
            // 1. 2번 단계에서 어느 한 축으로 잘라도 실 이미즈가 너무 크면 문제가 있기 때문에 좀 줄임
            if (contentSize.width / display_height >= actualSize.width / actualSize.height) {
                // 세로로 먼저 클리핑
                if (actualSize.height > display_height) {
                    scaledSize.width = display_height * actualSize.width / actualSize.height;
                    scaledSize.height = display_height;
                }
            }
            else {
                // 가로로 클리핑
                if (actualSize.width > contentSize.width) {
                    scaledSize.width = contentSize.width;
                    scaledSize.height = contentSize.width * actualSize.height / actualSize.width;
                }
            }
            
            RBSizeF rect_size = scaledSize;
            
            // 2. contentSize.width x display_height 에 들어갈 수 있도록 clip
            if (scaledSize.width > contentSize.width) {
                // 세로로 잘랐는데 가로가 넘치면
                rect_size.height = scaledSize.height * contentSize.width / scaledSize.width;
                rect_size.width = contentSize.width;
            }
            if (scaledSize.height > display_height) {
                // 가로로 잘랐는데 세로가 넘치면
                rect_size.width = scaledSize.width * display_height / scaledSize.height;
                rect_size.height = display_height;
            }
            
            posX = (contentSize.width - rect_size.width) / 2 + _renderer.marginLeft;
            posY = (display_height - rect_size.height) / 2 + _renderer.marginTop;
            
            [_renderer deliverImageRenderable:imgSrc rect:RBRectFMake(posX, posY, posX + rect_size.width, posY + rect_size.height)];
            
            // 캡션이 있으면 딜리버
            if (imgCaption != nil) {
                RBBomRendererContext *centerContext = [[RBBomRendererContext alloc] init];
                centerContext.align = RBBomAlignCenter;
                
                [self deliverAlignedTextRenderable:centerContext
                                              text:imgCaption
                                                 x:posX
                                                 y:posY + rect_size.height + (_renderer.lineHeight / 2)
                                    measuredLength:captionWidth
                                          nodeInfo:from];
            }
            
            if (node.nextNode == nil)
                return nil;
            return [RBBomNodeInfo nodeInfoWithTagNode:(RBBomTagNode *)node.nextNode];
        }
        else {
            // 다음 페이지에 풀스크린으로 그리도록
            return [RBBomNodeInfo nodeInfoWithTagNode:(RBBomTagNode *)node];
        }
        
    }
    else {
        
        // fullscreen이 아닐경우, 이미지 크기가 화면보다 크면 줄인다.
        const NSInteger MAX_NONFULLSCREEN_IMAGE_WIDTH = (NSInteger) _renderer.contentWidth;
        const NSInteger MAX_NONFULLSCREEN_IMAGE_HEIGHT = (NSInteger) (_renderer.contentHeight - _renderer.lineHeight - captionHeight);
        
        if (imgWidth > MAX_NONFULLSCREEN_IMAGE_WIDTH) {
            imgHeight = imgHeight * MAX_NONFULLSCREEN_IMAGE_WIDTH / imgWidth;
            imgWidth = MAX_NONFULLSCREEN_IMAGE_WIDTH;
        }
        if (imgHeight > MAX_NONFULLSCREEN_IMAGE_HEIGHT) {
            imgWidth = imgWidth * MAX_NONFULLSCREEN_IMAGE_HEIGHT / imgHeight;
            imgHeight = MAX_NONFULLSCREEN_IMAGE_HEIGHT;
        }
        
        if (posY + imgHeight + captionHeight > _renderer.canvasSize.height - _renderer.marginBottom) {
            // 현재 페이지에 넣을 수 없는 경우 다음페이지로 넘긴다.
            return [RBBomNodeInfo nodeInfoWithTagNode:(RBBomTagNode *)node];
        }
        else {
            // 이미지 Renderable 추가
            float img_x = posX;
            
            switch (imgAlign) {
                case RBBomAlignLeft:
                    img_x = posY;
                    break;
                case RBBomAlignCenter:
                    img_x = (_renderer.canvasSize.width - imgWidth) / 2;
                    break;
                    
                case RBBomAlignRight:
                    img_x = _renderer.canvasSize.width - _renderer.marginRight - imgWidth; 
                    break;
            }
            
            // 이미지 딜리버
            [_renderer deliverImageRenderable:imgSrc rect:RBRectFMake(img_x, posY, img_x + imgWidth, posY + imgHeight)];
            [self moveY:imgHeight + _renderer.lineHeight];
            [self initPositionX];
            
            
            // 캡션이 있으면 딜리버
            if (imgCaption != nil) {
                [_renderer deliverTextRenderable:[[RBBomRendererContext alloc] init] text:imgCaption
                                              x:img_x
                                              y:posY
                                       nodeInfo:from];
                [self moveY:captionHeight];
                [self initPositionX];
            }
        }
    }
    
    return nil;
}

- (RBPointF)applySubscriptPoint:(RBPointF)point {
    assert(currentContext != nil);

    // 윗첨자는 글자 상단 살짝 위에, 아랫첨자는 글자 아래 라인에 맞게
    if (currentContext.subscript == RBBomSubscriptSup)
        return RBPointFMake(point.x, point.y - ([_renderer getFontHeight] / 6));
    else if (currentContext.subscript == RBBomSubscriptSub)
        return RBPointFMake(point.x, point.y + ([_renderer getFontHeight] / 2));
    
    // RBBomSubscriptNone or RBBomSubscriptSub
    return point;
}

- (RBBomRendererContext *)makeContextFromSupTagNode:(RBBomTagNode *)node {
    RBBomRendererContext *rendContext;
    
    rendContext = [self baseContextFromCurrentContext];
    rendContext.subscript = RBBomSubscriptSup;
    
    return rendContext;
}

- (RBBomRendererContext *)makeContextFromSubTagNode:(RBBomTagNode *)node {
    RBBomRendererContext *rendContext;
    
    rendContext = [self baseContextFromCurrentContext];
    rendContext.subscript = RBBomSubscriptSub;
    
    return rendContext;
}

// FONT 태그에서 렌더러 컨텍스트 뽑기
- (RBBomRendererContext *)makeContextFromFontTagNode:(RBBomTagNode *)node {
    RBBomRendererContext *rendContext;
    
    rendContext = [self baseContextFromCurrentContext];
    
    //String fontFace = node.getStringAttr("face");
    NSString *fontColor = [node stringAttribute:@"color"]; // use
    NSInteger fontSize = [node integerAttribute:@"size" defaultValue:-1]; // use
    NSInteger fontAlign = getAlign([node stringAttribute:@"align"], rendContext.align);
    //boolean fontBold = node.getBooleanAttr("bold", false);
    //boolean fontItalic = node.getBooleanAttr("italic", false);
    
    //if (fontFace != null)
    //    readContext.setFontFace(fontFace);
    
    if (fontSize != -1)
        rendContext.fontSize = fontSize;
    
    if (fontColor != nil)
        rendContext.fontColor = fontColor;
    
    rendContext.align = (RBBomAlign)fontAlign;
    
    return rendContext;
}

- (RBBomRendererContext *)baseContextFromCurrentContext {
    if (currentContext == nil) {
        return [[RBBomRendererContext alloc] init];
    }
    else {
        return [[RBBomRendererContext alloc] initWithContext:currentContext];
    }
}

- (void)initPosition {
    [self initPositionX];
    [self initPositionY];
}

- (void)initPositionX {
    posX = _renderer.marginLeft;
}

- (void)initPositionY {
    posY = _renderer.marginTop;
}

- (void)moveX:(float)length {
    posX += length;
}

- (void)moveY:(float)length {
    posY += length;
}

- (void)applyContext {
    if ([contextStack count] > 0) {
        currentContext = [contextStack lastObject];
        
        [_renderer changeFontSize:currentContext.fontSize ofSubscript:currentContext.subscript];
        [_renderer changeFontColor:currentContext.fontColor];
    }
    else {
        currentContext = nil;
    }
}

- (void)pushContext:(RBBomRendererContext *)rc {
    [contextStack addObject:rc];
    [self applyContext];
}

- (void)popContext {
    if ([contextStack count] > 1)
        [contextStack removeLastObject];
    
    [self applyContext];
}

- (RBBomRendererContext *)topContext {
    return currentContext;
}

RBBomAlign getAlign(NSString *value, RBBomAlign defaultValue) {
    if (value == nil)
        return defaultValue;
    
    if ([value caseInsensitiveCompare:@"left"] == NSOrderedSame)
        return RBBomAlignLeft;
    else if ([value caseInsensitiveCompare:@"right"] == NSOrderedSame)
        return RBBomAlignRight;
    else if ([value caseInsensitiveCompare:@"center"] == NSOrderedSame)
        return RBBomAlignCenter;
    
    return defaultValue;
}

static BOOL isEndingSpecialChar(unichar ch) {
    switch (ch) {
        case ')':
        case '"':
        case '\'':
        case '!':
        case ',':
        case '.':
        case '>':
        case '?':
        case '}':
            return YES;
        case 0x201D:  //”
        case 0x2019:  //’
            return YES;
        default:
            return NO;
    }
}

static BOOL isSpecialChar(unichar ch) {    
    switch (ch) {
        case '(':
        case ')':
        case '"':
        case '\'':
        case '!':
        case ',':
        case '.':
        case '<':
        case '>':
        case '?':
        case '{':
        case '}':
            return YES;
        default:
            return NO;
    }
}

static BOOL isAlphaOrNumber(unichar ch) {
    if (ch >= '0' && ch <= '9')
        return YES;
    if (ch >= 'A' && ch <= 'Z')
        return YES;
    if (ch >= 'a' && ch <= 'z')
        return YES;
    
    return NO;
}

@end
