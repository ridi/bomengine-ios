//
//  RBBomStringBuilder.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 2/11/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

@interface RBBomStringBuilder : NSObject

- (void)appendCharacter:(unichar)ch;
- (void)appendString:(NSString *)string;
- (void)deleteLastCharacter;
- (void)deleteCharactersFromIndex:(NSUInteger)index;
- (void)clear;

- (NSString *)toString;
- (NSString *)substringFromIndex:(NSUInteger)index;

- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;

@end
