//
//  RBBomTagNode.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomNode.h"

typedef enum {
    RBBomNodeTagPage,
    RBBomNodeTagImg,
    RBBomNodeTagFont,
    RBBomNodeTagLink,
    RBBomNodeTagIndex,
    RBBomNodeTagSup,
    RBBomNodeTagSub,
    RBBomNodeTagText,
    RBBomNodeTagNothing,
} RBBomNodeTag;


typedef enum {
    RBBomTagStatusOpener,
    RBBomTagStatusCloser,
    RBBomTagStatusFinished,
    RBBomTagStatusUnknown = 99,
} RBBomTagStatus;


@class RBBomAttribute;


@interface RBBomTagNode : RBBomNode

@property (nonatomic) RBBomNodeTag tagType;
@property (nonatomic, readonly) RBBomTagStatus tagStatus;
@property (nonatomic) NSInteger rawOffset;
@property (nonatomic, copy) NSString *innerText;

- (id)initWithTag:(RBBomNodeTag)aTagType rawOffset:(NSInteger)offset;

+ (RBBomNodeTag)tagTypeFromName:(NSString *)tagName;
+ (NSString *)tagNameFromType:(RBBomNodeTag)tagType;

- (void)addAttribute:(RBBomAttribute *)attribute;
- (void)setTagStatus:(RBBomTagStatus)status;

- (NSString *)stringAttribute:(NSString *)key;
- (NSInteger)integerAttribute:(NSString *)key defaultValue:(NSInteger)defaultValue;
- (BOOL)boolAttribute:(NSString *)key defaultValue:(BOOL)defaultValue;

@end
