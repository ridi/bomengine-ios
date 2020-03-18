//
//  RBBomTextRenderable.m
//  RBBomReaderEngine
//
//  Created by Earus on 1/26/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomTextRenderable.h"
#import "RBBomRendererContext.h"
#import "RBBomRenderer.h"

@implementation RBBomTextRenderable

- (id)initWithText:(NSString*)aText {
    if ((self = [super init])) {
        _text = aText;
    }
    
    return self;
}


- (void)render:(id<RBBomRenderer>)renderer {
    [renderer changeFontSize:self.styleContext.fontSize ofSubscript:self.styleContext.subscript];
    [renderer changeFontColor:self.styleContext.fontColor];
    
    [renderer drawText:_text rect:self.rect context:self.styleContext];
}

@end
