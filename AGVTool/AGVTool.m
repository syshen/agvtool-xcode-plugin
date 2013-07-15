//
//  AGVTool.m
//  AGVTool
//
//  Created by Shen Steven on 7/13/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVTool.h"
#import "AGVShellHandler.h"
#import "AGVWorkspaceManager.h"
#import "AGVVersionInputWindowController.h"
#import "AGVBuildInputWindowController.h"

@interface AGVTool ()

@property (nonatomic, strong) NSMenuItem *bumpItem;
@property (nonatomic, strong) NSMenuItem *whatVerItem;
@property (nonatomic, strong) NSMenuItem *createVerItem;
@property (nonatomic, strong) NSMenuItem *createMarketingVerItem;
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation AGVTool

+ (void)pluginDidLoad:(NSBundle *)plugin {
  static id sharedPlugin = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedPlugin = [[self alloc] initWithBundle:plugin];
  });
}

- (id)initWithBundle:(NSBundle *)plugin {
  if (self = [super init]) {
    _bundle = plugin;
    [self addMenuItems];
  }
  return self;
}

- (void)addMenuItems {
  NSMenuItem *topMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
  if (topMenuItem) {
    NSMenuItem *agvtoolMenu = [[NSMenuItem alloc] initWithTitle:@"Version Tool" action:nil keyEquivalent:@""];
    agvtoolMenu.submenu = [[NSMenu alloc] initWithTitle:@"Version Tool"];
    
    self.bumpItem = [[NSMenuItem alloc] initWithTitle:@"Bump"
                                               action:@selector(agvtoolBump)
                                        keyEquivalent:@""];
    
    self.whatVerItem = [[NSMenuItem alloc] initWithTitle:@"Current Version"
                                                  action:@selector(agvtoolWhatVersion)
                                           keyEquivalent:@""];
    
    self.createVerItem = [[NSMenuItem alloc] initWithTitle:@"New Version"
                                                 action:@selector(agvtoolNewVersion)
                                          keyEquivalent:@""];
    
    self.createMarketingVerItem = [[NSMenuItem alloc] initWithTitle:@"New Marketing Version"
                                                          action:@selector(agvtoolNewMarketingVersion)
                                                   keyEquivalent:@""];
    
    [self.bumpItem setTarget:self];
    [self.whatVerItem setTarget:self];
    [self.createVerItem setTarget:self];
    [self.createMarketingVerItem setTarget:self];
    
    [[agvtoolMenu submenu] addItem:self.bumpItem];
    [[agvtoolMenu submenu] addItem:self.whatVerItem];
    [[agvtoolMenu submenu] addItem:self.createVerItem];
    [[agvtoolMenu submenu] addItem:self.createMarketingVerItem];
    [[topMenuItem submenu] insertItem:agvtoolMenu atIndex:[topMenuItem.submenu indexOfItemWithTitle:@"Build For"]];
  }
}

- (void)dealloc {
  [super dealloc];
  [self.bumpItem release];
  [self.whatVerItem release];
  [self.createVerItem release];
  [self.createMarketingVerItem release];
  
}
- (void)agvtoolBump {
 
  [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                           withArgs:@[@"bump"]
                         directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                         completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {
                           
                           [self alertWithMessage:standardOutput];
                           
                         }];
  
}

- (void)agvtoolWhatVersion {

  [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                          withArgs:@[@"vers"]
                         directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                        completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {
                          
                          NSInteger version = 0;
                          if ([self parseVersionFromOutput:standardOutput version:&version]) {
                            
                            [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                                                    withArgs:@[@"what-marketing-version"]
                                                   directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                                                  completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {
                                                    
                                                    NSInteger major = 0;
                                                    NSInteger minor = 0;
                                                    if([self parseMarketingVersionFromOutput:standardOutput
                                                                                majorVersion:&major
                                                                                minorVersion:&minor]) {
                                                      
                                                      NSString *string = [NSString stringWithFormat:@"Marketing version: %ld.%ld\nVersion:%ld", major, minor, version];
                                                     
                                                      [self alertWithMessage:string];
                                                      
                                                    } else {
                                                      
                                                      [self alertWithMessage:[NSString stringWithFormat:@"Unable to get marketing version: %@", standardOutput]];
                                                      
                                                    }
                                                  }];
                          }
                          
                          
                        }];
  

}


- (void)agvtoolNewVersion {
  
  [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                          withArgs:@[@"vers"]
                         directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                        completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {
                          
                          NSLog(@"output: %@", standardOutput);
                          NSInteger version = 0;
                          BOOL versionFound = [self parseVersionFromOutput:standardOutput version:&version];
                          if (versionFound) {
                            
                            AGVBuildInputWindowController *buildInput = [[AGVBuildInputWindowController alloc] initWithVersion:version completionHandler:^(NSInteger newVer) {
                              
                              NSString *arg = [NSString stringWithFormat:@"%ld", newVer];
                              
                              [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                                                      withArgs:@[@"new-version", arg]
                                                     directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                                                    completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {

                                                      [self alertWithMessage:standardOutput];
                                                   
                                                    }];

                              
                              
                            }];
                            [buildInput showWindow:self];

                          } else {
                            
                            [self alertWithMessage:@"No version found"];
                            
                          }
                        }];
  
  
}

- (void)agvtoolNewMarketingVersion {
  
  [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                          withArgs:@[@"what-marketing-version"]
                         directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                        completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {
                          
                          NSInteger major = 0;
                          NSInteger minor = 0;
                          BOOL versionFound = [self parseMarketingVersionFromOutput:standardOutput
                                                   majorVersion:&major
                                                   minorVersion:&minor];
                          
                          if (versionFound) {
                            AGVVersionInputWindowController *versionInput = [[AGVVersionInputWindowController alloc] initWithMajorVersion:major minorVersion:minor completionHandler:^(NSInteger newMajor, NSInteger newMinor){
                              
                              NSString *marketVerString = [NSString stringWithFormat:@"%ld.%ld", newMajor, newMinor];
                              NSLog(@"new version: %@", marketVerString);
                              [AGVShellHandler runShellCommand:@"/usr/bin/agvtool"
                                                      withArgs:@[@"new-marketing-version", marketVerString]
                                                     directory:[AGVWorkspaceManager currentWorkspaceDirectoryPath]
                                                    completion:^(NSTask *t, NSString *standardOutput, NSString *standardErr) {
                                                      
                                                      [self alertWithMessage:standardOutput];
                                                      
                                                    }];

                            }];
                            [versionInput showWindow:self];

                          } else {
                            
                            [self alertWithMessage:@"No version found"];

                          }
                        }];
}

- (BOOL)parseVersionFromOutput:(NSString*)standardOutput version:(NSInteger*)version {
  NSString *digits = [standardOutput stringByTrimmingCharactersInSet:
                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
  
  if (digits.length) {
    *version = [digits integerValue];
    return YES;
  } else {
    return NO;
  }
  
}

- (BOOL)parseMarketingVersionFromOutput:(NSString*)standardOutput majorVersion:(NSInteger*)major minorVersion:(NSInteger*)minor {
  
  NSError *error = nil;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.\\d+" options:0 error:&error];
  NSUInteger numberOfMatches = [regex numberOfMatchesInString:standardOutput options:0 range:NSMakeRange(0, [standardOutput length])];
  if (numberOfMatches) {
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:standardOutput options:0 range:NSMakeRange(0, [standardOutput length])];
    
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
      NSString *substringForFirstMatch = [standardOutput substringWithRange:rangeOfFirstMatch];
      
      NSArray *digits = [substringForFirstMatch componentsSeparatedByString:@"."];
      if (digits.count >= 2) {
        *major = [digits[0] integerValue];
        *minor = [digits[1] integerValue];
        return YES;
      }
    }
  }
  return NO;
}

- (void)alertWithMessage:(NSString*)message {
  
  NSAlert *alert = [NSAlert alertWithMessageText:message
                                   defaultButton:@"OK"
                                 alternateButton:nil
                                     otherButton:nil
                       informativeTextWithFormat:@""];
  [alert runModal];

}

@end
