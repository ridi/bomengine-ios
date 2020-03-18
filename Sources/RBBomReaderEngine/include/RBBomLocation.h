//
//  RBBomLocation.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 2/26/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RBBomLocation <NSObject>

- (NSComparisonResult)compareTo:(id<RBBomLocation>)location;
- (NSInteger)rawOffset;

@end


@interface RBBomRawLocation : NSObject <RBBomLocation, NSCoding>

- (id)initWithOffset:(NSInteger)anOffset;

+ (id)rawLocationWithOffset:(NSInteger)offset;

@end
