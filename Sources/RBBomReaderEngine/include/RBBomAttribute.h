//
//  RBBomAttribute.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBBomAttribute : NSObject {
    NSString *key;
    NSString *value;
}

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;

- (id)initWithKey:(NSString *)key value:(NSString *)value;

@end
