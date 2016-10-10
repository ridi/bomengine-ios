//
//  RBBomUtil.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/27/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#ifndef RBBomUtil_h
#define RBBomUtil_h

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef struct {
        float left;
        float top;
        float right;
        float bottom;
    } RBRectF;
    
    typedef CGSize RBSizeF;
    typedef CGPoint RBPointF;
    
    RBSizeF RBSizeFMake(float width, float height);
    RBRectF RBRectFMake(float left, float top, float right, float bottom);
    RBPointF RBPointFMake(float x, float y);
    
    BOOL RBRectFContainsPointF(RBRectF rect, RBPointF point);
    RBRectF RBRectFUnion(RBRectF r1, RBRectF r2);
    
    CGPoint RBPointFToCGPoint(RBPointF point);
    CGRect RBRectFToCGRect(RBRectF rect);
    
#ifdef __cplusplus
}
#endif

#endif
