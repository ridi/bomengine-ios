//
//  RBBomRendererContext.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomRendererContext.h"

@implementation RBBomRendererContext

- (id)init {
    if ((self = [super init])) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithContext:(RBBomRendererContext *)baseContext {
    if ((self = [super init])) {
        [self setDefaults];
        _fontSize = baseContext.fontSize;
        _fontColor = baseContext.fontColor;
        _subscript = baseContext.subscript;
    }
    return self;
}

- (void)setDefaults {
    _fontSize = 3;
    _align = RBBomAlignLeft;
    _subscript = RBBomSubscriptNone;
    _wrapped = false;
}

@end
