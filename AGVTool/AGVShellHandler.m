//
//  AGVShellHandler.m
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVShellHandler.h"

@implementation AGVShellHandler

+ (void)runShellCommand:(NSString *)command withArgs:(NSArray *)args directory:(NSString *)directory completion:(void(^)(NSTask *t, NSString *standardOutput, NSString *standardErr))completion {
  __block NSMutableData *taskOutput = [NSMutableData new];
  __block NSMutableData *taskError  = [NSMutableData new];
  
  NSTask *task = [NSTask new];
  
//  NSLog(@"command directory: %@", directory);
  task.currentDirectoryPath = directory;
  task.launchPath = command;
  task.arguments  = args;
  
  task.standardOutput = [NSPipe pipe];
  task.standardError  = [NSPipe pipe];
  
  [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
    [taskOutput appendData:[file availableData]];
  }];
  
  [[task.standardError fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
    [taskError appendData:[file availableData]];
  }];
  
  [task setTerminationHandler:^(NSTask *t) {
    [t.standardOutput fileHandleForReading].readabilityHandler = nil;
    [t.standardError fileHandleForReading].readabilityHandler  = nil;
    NSString *output = [[NSString alloc] initWithData:taskOutput encoding:NSUTF8StringEncoding];
    NSString *error = [[NSString alloc] initWithData:taskError encoding:NSUTF8StringEncoding];
    NSLog(@"Shell command output: %@", output);
    NSLog(@"Shell command error: %@", error);
    if (completion) completion(t, output, error);
  }];
  
  @try {
    [task launch];
  }
  @catch (NSException *exception) {
    NSLog(@"Failed to launch: %@", exception);
  }
}


@end
