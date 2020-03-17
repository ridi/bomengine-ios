//
//  RBBomDataReader.m
//  RBBomReaderEngine
//
//  Created by Earus on 1/24/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomDataReader.h"

@implementation RBBomDataReader {
    NSString *contents;
	NSInteger remember;
	NSInteger totalLength;
}

- (id)initWithFilePath:(NSString *)path {
    if ((self = [super init])) {
        _pos = 0;
        remember = 0;
        
        contents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        totalLength = [contents length];
    }
    return self;
}

- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        _pos = 0;
        remember = 0;
        
        contents = string;
        totalLength = [contents length];
    }
    return self;
}


- (unichar)getChar {
    unichar c = CFStringGetCharacterAtIndex((CFStringRef)contents, _pos);
    //unichar c = [contents characterAtIndex:pos];
    [self goForward:1];
    
    return c;
}

- (unichar)getCharSkipWhite {
    while ([self isReadable]) {
        unichar c = [self getChar];
        
        // check white space
        if ([self isWhiteSpace:c])
            continue;
        
        return c;
    }
     
    return 0;
}

- (NSString *)readUntil:(unichar)what {
    NSInteger searchPos = _pos;
    
    while ([self isReadable]) {
        unichar c = [self getChar];
        
        if (c == what) {
            [self goBackward:1];
            break;
        }   
    }
    
    return [contents substringWithRange:NSMakeRange(searchPos, _pos - searchPos)];
}

- (NSString *)getNextToken {
    NSInteger searchPos = _pos;
    
    while ([self isReadable]) {
        unichar c = [self getChar];

        if ([self isWhiteSpace:c] ||
            !([self isLetterOrDigit:c])) {
            [self goBackward:1];
            return [contents substringWithRange:NSMakeRange(searchPos, _pos - searchPos)];
        }
    }
            
    return nil;
}

- (unichar)getCurrPosChar {
    return CFStringGetCharacterAtIndex((CFStringRef)contents, _pos);
//    return [contents haracterAtIndex:pos];
}

- (BOOL)isReadable {
    return _pos < totalLength;
}

- (void)goBackward:(NSInteger)distance {
    _pos -= distance;
}

- (void)goForward:(NSInteger)distance {
    _pos += distance;
}

- (void)backToRememberedPos {
    _pos = remember;
}

- (void)rememberCurrPos {
    remember = _pos;
}

- (NSString *)getWholeText {
    return contents;
}

- (NSInteger)getRememberedPos {
    return remember;
}

- (BOOL)isWhiteSpace:(unichar)c {
    return [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c];
}

- (BOOL)isLetterOrDigit:(unichar)c {
    if ([[NSCharacterSet letterCharacterSet] characterIsMember:c])
        return YES;
    if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c])
        return YES;
    
    return NO;
}

@end
