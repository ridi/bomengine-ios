//
//  RBBomParser.h
//  RBBomReaderEngine
//
//  Created by Earus on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBBomDataReader;
@class RBBomTagNode;

@interface RBBomParser : NSObject

@property (nonatomic, readonly) RBBomTagNode *rootNode;

- (id)initWithReader:(RBBomDataReader*)reader;

- (void)parseWithEscapeTags:(BOOL)escapeTags;

+ (NSString *)removeTag:(NSString *)plainText;

@end
