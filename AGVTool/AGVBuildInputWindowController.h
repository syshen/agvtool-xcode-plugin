//
//  AGVBuildInputWindowController.h
//  AGVTool
//
//  Created by Shen Steven on 7/14/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AGVBuildInputWindowController : NSWindowController

- initWithVersion:(NSInteger)ver completionHandler:(void (^)(NSInteger newVer))completionHandler;

@end
