//
//  RBBomAttribute.m
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomAttribute.h"

@implementation RBBomAttribute

@synthesize key, value;

- (id)initWithKey:(NSString *)aKey value:(NSString *)aValue {
    if ((self = [super init])) {
        self.key = aKey;
        self.value = aValue;
    }
    return self;
}


@end
