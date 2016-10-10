//
//  RBBomRendererContext.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

typedef enum {
    RBBomAlignLeft,
    RBBomAlignCenter,
    RBBomAlignRight
} RBBomAlign;

typedef enum {
    RBBomSubscriptNone,
    RBBomSubscriptSup,
    RBBomSubscriptSub
} RBBomSubscript;


@interface RBBomRendererContext : NSObject

@property (nonatomic) NSInteger fontSize;
@property (nonatomic) RBBomAlign align;
@property (nonatomic) RBBomSubscript subscript;
@property (nonatomic) BOOL wrapped;
@property (nonatomic, copy) NSString *fontColor;

- (id)initWithContext:(RBBomRendererContext *)baseContext;

@end