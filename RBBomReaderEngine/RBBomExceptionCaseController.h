//
//  RBBomExceptionCaseController.h
//  RBBomReaderEngine
//
//  Created by Hyunwoo on 11. 3. 9..
//  Copyright 2011 YUTAR. All rights reserved.
//

/*
 * 리디북스 뷰어엔진 V2에서의 예외처리
 * 
 * 1) 태그와 태그 사이의 엔터(\n) 제거
 * 2) IMG 태그가 fullScreen 속성을 가지고 있고 바로 다음에 PAGE태그가 올 경우 PAGE 태그 제거
 * 
 */

@class RBBomNodeManager;

@interface RBBomExceptionCaseController : NSObject

+ (void)removeExceptionCase:(RBBomNodeManager *)nodeMgr;

@end
