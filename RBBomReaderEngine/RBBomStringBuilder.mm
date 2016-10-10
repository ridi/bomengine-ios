//
//  RBBomStringBuilder.mm
//  RBBomReaderEngine
//
//  Created by Hyunwoo Nam on 2/11/11.
//  Copyright 2011 YUTAR. All rights reserved.
//

#import "RBBomStringBuilder.h"

#include <vector>

@interface RBBomStringBuilderImpl : NSObject

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


@implementation RBBomStringBuilderImpl {
    std::vector<unichar> sb;
}

- (void)appendCharacter:(unichar)ch {
    sb.push_back(ch);
}

- (void)appendString:(NSString *)string {
    const UniChar *buffer = CFStringGetCharactersPtr((CFStringRef)string);
    if (buffer == NULL) {
        UniChar *buf = new UniChar[string.length];
        CFStringGetCharacters((CFStringRef)string, CFRangeMake(0, string.length), buf);
        buffer = buf;
        sb.insert(sb.end(), buffer, buffer + string.length);
        delete[] buf;
    }
    else {
        sb.insert(sb.end(), buffer, buffer + string.length);
    }
}

- (void)deleteLastCharacter {
    sb.pop_back();
}

- (void)deleteCharactersFromIndex:(NSUInteger)index {
    sb.erase(sb.begin() + index, sb.end());
}

- (void)clear {
    sb.clear();
}

- (NSString *)toString {
    return [NSString stringWithCharacters:(const unichar *)sb.data() length:sb.size()];
}

- (NSUInteger)length {
    return sb.size();
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return sb[index];
}

- (NSString *)substringFromIndex:(NSUInteger)index {
    return [NSString stringWithCharacters:(const unichar *)sb.data() + index length:sb.size() - index];
}

@end


@implementation RBBomStringBuilder {
    RBBomStringBuilderImpl *impl;
}

- (id)init {
    if ((self = [super init])) {
        impl = [[RBBomStringBuilderImpl alloc] init];
    }
    return self;
}


- (void)appendCharacter:(unichar)ch {
    return [impl appendCharacter:ch];
}

- (void)appendString:(NSString *)string {
    return [impl appendString:string];
}

- (void)deleteLastCharacter {
    return [impl deleteLastCharacter];
}

- (void)deleteCharactersFromIndex:(NSUInteger)index {
    return [impl deleteCharactersFromIndex:index];
}

- (void)clear {
    return [impl clear];
}

- (NSString *)toString {
    return [impl toString];
}

- (NSUInteger)length {
    return [impl length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [impl characterAtIndex:index];
}

- (NSString *)substringFromIndex:(NSUInteger)index {
    return [impl substringFromIndex:index];
}

@end