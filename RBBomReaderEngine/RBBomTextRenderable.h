//
//  RBBomTextRenderable.h
//  RBBomReaderEngine
//
//  Created by Earus on 1/26/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomRenderable.h"

@protocol RBBomRenderer;

@interface RBBomTextRenderable : RBBomRenderable

@property (nonatomic) NSInteger fontSize;
@property (nonatomic, copy) NSString *fontColor;
@property (nonatomic, copy) NSString *text;

- (id)initWithText:(NSString*)aText;

- (void)render:(id<RBBomRenderer>)renderer;

@end
