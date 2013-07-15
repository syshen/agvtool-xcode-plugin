//
//  AGVWorkspaceManager.m
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVWorkspaceManager.h"

@implementation AGVWorkspaceManager

+ (NSString *)currentWorkspaceDirectoryPath {
  id workspace = [self workspaceForKeyWindow];
  NSString *workspacePath = [[workspace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
  return [workspacePath stringByDeletingLastPathComponent];
}

+ (id)workspaceForKeyWindow {
  NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
  
  for (id controller in workspaceWindowControllers) {
    if ([[controller valueForKey:@"window"] valueForKey:@"isKeyWindow"]) {
      NSLog(@"%@", controller);
      return [controller valueForKey:@"_workspace"];
      
    }
  }
  return nil;
}


@end
