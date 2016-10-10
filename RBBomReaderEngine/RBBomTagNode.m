//
//  RBBomTagNode.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomTagNode.h"
#import "RBBomAttribute.h"

static NSString *TAG_NAMES[] = {
    @"PAGE",
    @"IMG",
    @"FONT",
    @"LINK",
    @"INDEX",
    @"SUP",
    @"SUB"
};


const static RBBomNodeTag TAG_VALUES[] = {
    RBBomNodeTagPage,
    RBBomNodeTagImg,
    RBBomNodeTagFont,
    RBBomNodeTagLink,
    RBBomNodeTagIndex,
    RBBomNodeTagSup,
    RBBomNodeTagSub
};

#define NUMBER_OF_TAG_NAMES     7


@implementation RBBomTagNode {
    NSMutableArray *_attributes;
}

- (id)initWithTag:(RBBomNodeTag)aTagType rawOffset:(NSInteger)anOffset {
    if ((self = [super init])) {
        _tagType = aTagType;
        _attributes = [[NSMutableArray alloc] init];
        _rawOffset = anOffset;
    }
    return self;
}


+ (RBBomNodeTag)tagTypeFromName:(NSString *)tagName {
    for (NSInteger i = 0; i < NUMBER_OF_TAG_NAMES; ++i) {
        if ([TAG_NAMES[i] caseInsensitiveCompare:tagName] == NSOrderedSame)
            return TAG_VALUES[i];
    }
    return RBBomNodeTagNothing;
}

+ (NSString *)tagNameFromType:(RBBomNodeTag)aTagType {
    for (NSInteger i = 0; i < NUMBER_OF_TAG_NAMES; ++i) {
        if (TAG_VALUES[i] == aTagType)
            return TAG_NAMES[i];
    }
    return @"TEXT";
}

- (void)addAttribute:(RBBomAttribute *)attribute {
    [_attributes addObject:attribute];
}

- (void)setTagStatus:(RBBomTagStatus)status {
    if (_tagType != RBBomNodeTagFont &&
        _tagType != RBBomNodeTagLink &&
        _tagType != RBBomNodeTagSup &&
        _tagType != RBBomNodeTagSub) {
        
        status = RBBomTagStatusFinished;
    }
    
    _tagStatus = status;
}


- (NSString *)innerText {
    return (_innerText != nil) ? _innerText : @"";
}


- (NSString *)stringAttribute:(NSString *)key {
    for (RBBomAttribute *attr in _attributes) {
        if ([attr.key caseInsensitiveCompare:key] == NSOrderedSame)
            return [attr value];
    }
    return nil;
}

- (NSInteger)integerAttribute:(NSString *)key defaultValue:(NSInteger)defaultValue {
    NSString *value = [self stringAttribute:key];
    if (value != nil)
        return [value integerValue];
    return defaultValue;
}

- (BOOL)boolAttribute:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSString *value = [self stringAttribute:key];
    if (value == nil)
        return defaultValue;
    
    if ([value caseInsensitiveCompare:@"true"] == NSOrderedSame)
        return YES;
    else if ([value caseInsensitiveCompare:@"false"] == NSOrderedSame)
        return NO;
    
    return defaultValue;
}


@end
