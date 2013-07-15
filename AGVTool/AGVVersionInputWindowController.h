//
//  AGVVersionInputWindowController.h
//  AGVTool
//
//  Created by Shen Steven on 7/14/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AGVVersionInputWindowController : NSWindowController

- (id) initWithMajorVersion:(NSInteger)major minorVersion:(NSInteger)minor completionHandler:(void (^)(NSInteger newMajor, NSInteger newMinor))completionHandler;

@end
