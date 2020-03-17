//
//  RBBomImageRenderable.m
//  RBBomReaderEngine
//
//  Created by Earus on 1/26/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomImageRenderable.h"
#import "RBBomRenderer.h"

@implementation RBBomImageRenderable

- (id)initWithImageSrc:(NSString*)aImgSrc {
    if ((self = [super init])) {
        _imgSrc = aImgSrc;
    }
    
    return self;
}


- (void)render:(id<RBBomRenderer>)renderer {
    if (_imgSrc != nil)
        [renderer drawImage:_imgSrc rect:self.rect];
}

@end
