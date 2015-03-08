//
//  AGVShellHandler.m
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVShellHandler.h"

@implementation AGVShellHandler

+ (void) runShellCommand:(NSString*)cmd withArgs:(NSArray*)args
               directory:(NSString*)dir completion:(TaskCompletion)comp {

  NSMutableData * taskOutput = NSMutableData.new,
                 * taskError = NSMutableData.new;
  
  NSTask *task = NSTask.new;
  
  //  NSLog(@"command directory: %@", directory);
  task.currentDirectoryPath = dir;
  task.launchPath = cmd;
  task.arguments  = args;
  
  task.standardOutput = NSPipe.pipe;
  task.standardError  = NSPipe.pipe;
  
  [task.standardOutput fileHandleForReading].readabilityHandler = ^(NSFileHandle *file) {
    [taskOutput appendData:file.availableData];
  };
  
  [task.standardError fileHandleForReading].readabilityHandler = ^(NSFileHandle *file) {
    [taskError appendData:file.availableData];
  };
  
  task.terminationHandler = ^(NSTask *t) {
    [t.standardOutput fileHandleForReading].readabilityHandler = nil;
    [t.standardError  fileHandleForReading].readabilityHandler = nil;
    NSString *output = [NSString.alloc initWithData:taskOutput encoding:NSUTF8StringEncoding],
              *error = [NSString.alloc initWithData:taskError  encoding:NSUTF8StringEncoding];
    NSLog(@"Shell command output: %@", output);
    NSLog(@"Shell command error: %@", error);
    if (comp) comp(t, output, error);
  };
  
  @try {
    [task launch];
  }
  @catch (NSException *exception) {
    NSLog(@"Failed to launch: %@", exception);
  }
}


@end
