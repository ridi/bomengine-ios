//
//  RBBomRendererContext.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RBBomAlign) {
    RBBomAlignLeft,
    RBBomAlignCenter,
    RBBomAlignRight
};

typedef NS_ENUM(NSInteger, RBBomSubscript) {
    RBBomSubscriptNone,
    RBBomSubscriptSup,
    RBBomSubscriptSub
};


@interface RBBomRendererContext : NSObject

@property (nonatomic) NSInteger fontSize;
@property (nonatomic) RBBomAlign align;
@property (nonatomic) RBBomSubscript subscript;
@property (nonatomic) BOOL wrapped;
@property (nonatomic, copy) NSString *fontColor;

- (id)initWithContext:(RBBomRendererContext *)baseContext;

@end
