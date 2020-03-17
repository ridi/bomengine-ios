//
//  RBBomDataReader.h
//  RBBomReaderEngine
//
//  Created by Earus on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBBomDataReader : NSObject

@property (nonatomic, readonly) NSInteger pos;

- (id)initWithFilePath:(NSString *)path;
- (id)initWithString:(NSString *)string;

- (unichar)getChar;
- (unichar)getCharSkipWhite;
- (unichar)getCurrPosChar;

- (BOOL)isReadable;

- (void)goBackward:(NSInteger)distance;
- (void)goForward:(NSInteger)distance;

- (void)backToRememberedPos;
- (void)rememberCurrPos;
- (NSInteger)getRememberedPos;

- (NSString *)getNextToken;
- (NSString *)readUntil:(unichar)what;
- (NSString *)getWholeText;

@end
