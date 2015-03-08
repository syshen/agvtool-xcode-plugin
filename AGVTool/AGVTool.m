//
//  AGVTool.m
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVShellHandler.h"
#import "AGVWorkspaceManager.h"
#import "AGVVersionInputWindowController.h"
#import "AGVBuildInputWindowController.h"

#define AGVTOOL @"/usr/bin/agvtool"


@import AppKit;

@interface AGVTool : NSObject

@property(nonatomic) NSMenuItem* bumpItem, *whatVerItem, *createVerItem, *createMarketingVerItem;
@property(nonatomic) NSBundle* bundle;

@end

@implementation AGVTool

+ (void)pluginDidLoad:(NSBundle*)plugin {

  static id sharedPlugin = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ sharedPlugin = [self.alloc initWithBundle:plugin]; });
}

- initWithBundle:(NSBundle*)plugin { if (!(self = [super init])) return nil;

  _bundle = plugin; [self addMenuItems];

  return self;
}

- (void) addMenuItems {

  NSMenuItem* topMenuItem;

  if (!(topMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"])) return;

  NSMenuItem* agvtoolMenu = [NSMenuItem.alloc initWithTitle:@"Version Tool"    action:nil keyEquivalent:@""];

      agvtoolMenu.submenu = [NSMenu.alloc initWithTitle:@"Version Tool"];

                _bumpItem = [NSMenuItem.alloc initWithTitle:@"Bump"            action:@selector(agvtoolBump) keyEquivalent:@""];

             _whatVerItem = [NSMenuItem.alloc initWithTitle:@"Current Version" action:@selector(agvtoolWhatVersion) keyEquivalent:@""];

           _createVerItem = [NSMenuItem.alloc initWithTitle:@"New Version"     action:@selector(agvtoolNewVersion) keyEquivalent:@""];

  _createMarketingVerItem = [NSMenuItem.alloc initWithTitle:@"New Marketing Version"
                                                           action:@selector(agvtoolNewMarketingVersion)
                                                    keyEquivalent:@""];

  for (id x in @[_bumpItem,_whatVerItem,_createVerItem,_createMarketingVerItem]){

   [x setTarget:self]; [agvtoolMenu.submenu addItem:x];

  }

  [topMenuItem.submenu insertItem:agvtoolMenu atIndex:[topMenuItem.submenu indexOfItemWithTitle:@"Build For"]];

}

- (void) agvtoolBump {

  [AGVShellHandler runShellCommand:AGVTOOL
                          withArgs:@[ @"bump" ]
                         directory:AGVWorkspaceManager.currentWorkspaceDirectoryPath
                        completion:^(NSTask* t, NSString* stdOut, NSString* stdErr) {

    [self alertWithMessage:stdOut];

  }];
}

- (void) agvtoolWhatVersion {

  [AGVShellHandler runShellCommand:AGVTOOL
                          withArgs:@[ @"vers" ]
                         directory:AGVWorkspaceManager.currentWorkspaceDirectoryPath
                        completion:^(NSTask* t, NSString* stdOut, NSString* stdErr) {

     NSInteger version = 0;
     if (![self parseVersionFromOutput:stdOut version:&version])
       return [self alertWithMessage:[NSString stringWithFormat:@"%@\n\nCannot Parse Version!\n%@", AGVWorkspaceManager.currentWorkspaceDirectoryPath, stdOut]];


     [AGVShellHandler runShellCommand:AGVTOOL
                             withArgs:@[ @"what-marketing-version" ]
                            directory:AGVWorkspaceManager.currentWorkspaceDirectoryPath
                           completion:^(NSTask* t, NSString* stdOut, NSString* stdErr) {

        NSInteger major = 0, minor = 0;
        [self alertWithMessage:
        [self parseMarketingVersionFromOutput:stdOut majorVersion:&major minorVersion:&minor]
        ? [NSString stringWithFormat:@"%@\n\nMarketing version: %ld.%ld\nVersion:%ld", AGVWorkspaceManager.currentWorkspaceDirectoryPath, major, minor, version]
        : [NSString stringWithFormat:@"%@\n\nUnable to get marketing version: %@", AGVWorkspaceManager.currentWorkspaceDirectoryPath,stdOut]];
    }];
  }];
}

- (void) agvtoolNewVersion {

  [AGVShellHandler runShellCommand:AGVTOOL
                          withArgs:@[ @"vers" ]
                         directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                        completion:^(NSTask* t, NSString* stdOut, NSString* standardErr) {

                            NSLog(@"output: %@", stdOut);
                            NSInteger version = 0;
                            BOOL versionFound = [self parseVersionFromOutput:stdOut version:&version];
                            if (versionFound) {

                              AGVBuildInputWindowController* buildInput = [AGVBuildInputWindowController.alloc
                                    initWithVersion:version
                                  completionHandler:^(NSInteger newVer) {

                                      NSString* arg = [NSString stringWithFormat:@"%ld", newVer];

                                      [AGVShellHandler
                                          runShellCommand:AGVTOOL
                                                 withArgs:@[ @"new-version", arg ]
                                                directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                                               completion:^(NSTask* t, NSString* stdOut, NSString* standardErr) {

                                                   [self alertWithMessage:stdOut];

                                               }];

                                  }];
                              [buildInput showWindow:self];

                            } else {

                              [self alertWithMessage:@"No version found"];
                            }
                        }];
}

- (void) agvtoolNewMarketingVersion {

  [AGVShellHandler runShellCommand:AGVTOOL
                          withArgs:@[ @"what-marketing-version" ]
                         directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                        completion:^(NSTask* t, NSString* stdOut, NSString* standardErr) {

               NSInteger major = 0;
               NSInteger minor = 0;
               BOOL versionFound = [self parseMarketingVersionFromOutput:stdOut majorVersion:&major minorVersion:&minor];

               if (versionFound) {
                 AGVVersionInputWindowController* versionInput = [AGVVersionInputWindowController.alloc
                     initWithMajorVersion:major
                             minorVersion:minor
                        completionHandler:^(NSInteger newMajor, NSInteger newMinor) {

                            NSString* marketVerString = [NSString stringWithFormat:@"%ld.%ld", newMajor, newMinor];
                            NSLog(@"new version: %@", marketVerString);
                            [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                                                    withArgs:@[ @"new-marketing-version", marketVerString ]
                                                   directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                                                  completion:^(NSTask* t, NSString* stdOut, NSString* standardErr) {

                                                      [self alertWithMessage:stdOut];

                                                  }];

                        }];
                 [versionInput showWindow:self];

               } else {

                 [self alertWithMessage:@"No version found"];
               }
           }];
}

- (BOOL) parseVersionFromOutput:(NSString*)stdOut version:(NSInteger*)version {

  NSString* digits = [stdOut stringByTrimmingCharactersInSet:NSCharacterSet.decimalDigitCharacterSet.invertedSet];

  return digits.length ? *version = [digits integerValue], YES : NO;
}

- (BOOL) parseMarketingVersionFromOutput:(NSString*)stdOut majorVersion:(NSInteger*)major minorVersion:(NSInteger*)minor {

  NSError* error = nil; NSUInteger numberOfMatches; NSRange  rangeOfFirstMatch;

  NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.\\d+" options:0 error:&error];

  if (!(numberOfMatches = [regex numberOfMatchesInString:stdOut options:0 range:NSMakeRange(0, [stdOut length])]))
    return NO;

  rangeOfFirstMatch = [regex rangeOfFirstMatchInString:stdOut options:0 range:NSMakeRange(0, stdOut.length)];

  if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
    NSString* substringForFirstMatch = [stdOut substringWithRange:rangeOfFirstMatch];

    NSArray* digits = [substringForFirstMatch componentsSeparatedByString:@"."];
    if (digits.count >= 2) {
      *major = [digits[0] integerValue];
      *minor = [digits[1] integerValue];
      return YES;
    }
  }
  return NO;
}

- (void) alertWithMessage:(NSString*)message {

  id x = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:nil
                           otherButton:nil               informativeTextWithFormat:@""];
  [x performSelectorOnMainThread:@selector(runModal)withObject:nil waitUntilDone:NO];
}

@end
