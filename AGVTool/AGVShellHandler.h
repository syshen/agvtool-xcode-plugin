//
//  AGVShellHandler.h
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGVShellHandler : NSObject
+ (void)runShellCommand:(NSString *)command withArgs:(NSArray *)args directory:(NSString *)directory completion:(void(^)(NSTask *t, NSString *standardOutput, NSString *standardErr))completion;
@end
