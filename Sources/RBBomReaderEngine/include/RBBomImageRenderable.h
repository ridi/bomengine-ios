//
//  RBBomImageRenderable.h
//  RBBomReaderEngine
//
//  Created by Earus on 1/26/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomRenderable.h"

@interface RBBomImageRenderable : RBBomRenderable

@property (nonatomic, copy) NSString *imgSrc;

- (id)initWithImageSrc:(NSString *)aImgSrc;

- (void)render:(id<RBBomRenderer>)renderer;

@end
