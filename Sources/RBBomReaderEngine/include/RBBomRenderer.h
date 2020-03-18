/*
 *  RBBomRenderer.h
 *  RBBomReaderEngine
 *
 *  Created by Earus on 1/26/11.
 *  Copyright 2011 YUTAR. All rights reserved.
 *
 */

#import "RBBomRendererContext.h"
#import "RBBomUtil.h"

@class RBBomRendererContext;
@class RBBomNodeInfo;

@protocol RBBomRenderer <NSObject>

- (void)prepare;
- (void)render;

@optional
- (void)drawText:(NSString *)text rect:(RBRectF)rect context:(RBBomRendererContext *)context;
- (void)drawImage:(NSString *)imageSrc rect:(RBRectF)rect;
 
- (BOOL)getImageSize:(NSString *)src size:(RBSizeF *)size;
 
- (float)measureText:(NSString *)text;
- (float)measureChar:(unichar)ch;
- (float)getFontHeight;
 
- (void)changeFontSize:(NSInteger)fontSize ofSubscript:(RBBomSubscript)subScript;
- (void)changeFontColor:(NSString *)color;
 
- (void)deliverTextRenderable:(RBBomRendererContext *)context text:(NSString *)aText x:(float)x y:(float)y nodeInfo:(RBBomNodeInfo *)nodeInfo;
- (void)deliverImageRenderable:(NSString *)imgSrc rect:(RBRectF)aRect;

- (void)resetGlyphSizeCache;

@required

- (RBSizeF)canvasSize;
- (float)contentWidth;
- (float)contentHeight;

- (float)marginLeft;
- (float)marginRight;
- (float)marginTop;
- (float)marginBottom;

- (float)lineHeight;

@end
