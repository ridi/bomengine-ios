//
//  RBBomLocation.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 2/26/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomLocation.h"

@implementation RBBomRawLocation {
  @private
    NSInteger offset;
}

- (id)initWithOffset:(NSInteger)anOffset {
    if ((self = [super init])) {
        offset = anOffset;
    }
    return self;
}

+ (void)load {
    [NSKeyedUnarchiver setClass:[self class] forClassName:@"RawLocation"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        offset = [decoder decodeIntegerForKey:@"offset"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:offset forKey:@"offset"];
}

+ (id)rawLocationWithOffset:(NSInteger)offset {
    return [[RBBomRawLocation alloc] initWithOffset:offset];
}


#pragma mark -

- (NSComparisonResult)compareTo:(id<RBBomLocation>)location {
    if (offset < [location rawOffset]) {
        return NSOrderedAscending;
    }
    else if (offset > [location rawOffset]) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSInteger)rawOffset {
    return offset;
}

@end
