//
//  RBBomRenderable.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/25/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomUtil.h"

@class RBBomRendererContext;
@protocol RBBomRenderer;

@interface RBBomRenderable : NSObject

@property (nonatomic) RBRectF rect;
@property (nonatomic, strong) RBBomRendererContext *styleContext;

- (void)render:(id<RBBomRenderer>)renderer;

@end
