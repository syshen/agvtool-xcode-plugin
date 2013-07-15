//
//  AGVBuildInputWindowController.m
//  AGVTool
//
//  Created by Shen Steven on 7/14/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "AGVBuildInputWindowController.h"

@interface AGVBuildInputWindowController ()
@property (nonatomic, assign) IBOutlet NSTextField *versionField;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, copy) void (^completionHandler)(NSInteger newVer);
@end

@implementation AGVBuildInputWindowController
- (id) initWithVersion:(NSInteger)ver completionHandler:(void (^)(NSInteger newVer))completionHandler {
  self = [super initWithWindowNibName:@"AGVBuildInputWindowController"];
  if (self) {
    self.completionHandler = completionHandler;
    self.version = ver;
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
  self.versionField.integerValue = self.version;
  
}

- (IBAction)saveButtonTapped:(id)sender {
  
  if (self.completionHandler) {
    self.completionHandler(self.versionField.integerValue);
  }
  [self close];

}
@end
