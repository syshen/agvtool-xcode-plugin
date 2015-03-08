//
//  AGVShellHandler.h
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TaskCompletion)(NSTask *t, NSString *stdOut, NSString *stdErr);

@interface AGVShellHandler : NSObject

+ (void) runShellCommand:(NSString*)cmd withArgs:(NSArray*)args
               directory:(NSString*)dir completion:(TaskCompletion)comp;
@end
