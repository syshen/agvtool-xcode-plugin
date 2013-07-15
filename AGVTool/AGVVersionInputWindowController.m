//
//  AGVVersionInputWindowController.m
//  AGVTool
//
//  Created by Shen Steven on 7/14/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVVersionInputWindowController.h"

@interface AGVVersionInputWindowController ()
@property (nonatomic, assign) IBOutlet NSTextField *majorVersionField;
@property (nonatomic, assign) IBOutlet NSTextField *minorVersionField;
@property (nonatomic, assign) NSInteger majorVersion;
@property (nonatomic, assign) NSInteger minorVersion;
@property (nonatomic, copy) void (^completionHandler)(NSInteger, NSInteger);
@end

@implementation AGVVersionInputWindowController

- (id) initWithMajorVersion:(NSInteger)major minorVersion:(NSInteger)minor completionHandler:(void (^)(NSInteger newMajor, NSInteger newMinor))completionHandler {
  self = [super initWithWindowNibName:@"AGVVersionInputWindowController"];
  if (self) {
    self.completionHandler = completionHandler;
    self.majorVersion = major;
    self.minorVersion = minor;
  }
  return self;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
  
  [super windowDidLoad];
  self.majorVersionField.integerValue = self.majorVersion;
  self.minorVersionField.integerValue = self.minorVersion;
  
}


- (IBAction)saveButtonTapped:(id)sender {
  
  if (self.completionHandler) {
    self.completionHandler(self.majorVersionField.integerValue, self.minorVersionField.integerValue);
  }
  [self close];
  
}
@end
