//
//  RBBomUtil.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/27/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomUtil.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    RBSizeF RBSizeFMake(float width, float height) {
        RBSizeF size;
        size.width = width;
        size.height = height;
        return size;
    }
    
    RBRectF RBRectFMake(float left, float top, float right, float bottom) {
        RBRectF rect;
        rect.left = left;
        rect.top = top;
        rect.right = right;
        rect.bottom = bottom;
        return rect;
    }
    
    RBPointF RBPointFMake(float x, float y) {
        RBPointF point;
        point.x = x;
        point.y = y;
        return point;
    }
    
    BOOL RBRectFContainsPointF(RBRectF rect, RBPointF point) {
        return (point.x >= rect.left && point.x < rect.right &&
                point.y >= rect.top && point.y < rect.bottom);
    }
    
    RBRectF RBRectFUnion(RBRectF r1, RBRectF r2) {
        return RBRectFMake(MIN(r1.left, r2.left), MIN(r1.top, r2.top),
                           MAX(r1.right, r2.right), MAX(r1.bottom, r2.bottom));
    }
    
    CGPoint RBPointFToCGPoint(RBPointF point) {
        return CGPointMake(point.x, point.y);
    }
    
    CGRect RBRectFToCGRect(RBRectF rect) {
        return CGRectMake(rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top);
    }
    
    
#ifdef __cplusplus
}
#endif
