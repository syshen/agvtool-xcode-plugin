//
//  AGVVersionInputWindowController.h
//  AGVTool
//
//  Created by Shen Steven on 7/14/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^MajMinCompletion)(NSInteger newMajor, NSInteger newMinor);

@interface AGVVersionInputWindowController : NSWindowController

- initWithMajorVersion:(NSInteger)maj minorVersion:(NSInteger)min completionHandler:(MajMinCompletion)comp;

@end
