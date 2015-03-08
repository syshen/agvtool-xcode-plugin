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

  return [[[self.workspaceForKeyWindow valueForKey:@"representingFilePath"]
                                       valueForKey:@"_pathString"] stringByDeletingLastPathComponent];
}

+ workspaceForKeyWindow {

                        /* workspaceWindowControllers */
  for (id controller in [NSClassFromString(@"IDEWorkspaceWindowController")
                                 valueForKey:@"workspaceWindowControllers"]) {

    if (![[[controller valueForKey:@"window"] valueForKey:@"isKeyWindow"] boolValue]) continue;
    NSLog(@"%@", controller);
    return [controller valueForKey:@"_workspace"];
  }
  return nil;
}

@end
