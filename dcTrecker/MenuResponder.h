//
//  MenuResponder.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/14/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MenuResponder : NSResponder

-(IBAction)newPlaylist:(id)sender;
-(IBAction)openDocument:(id)sender;
-(IBAction)saveDocument:(id)sender;
-(IBAction)saveDocumentAs:(id)sender;

@end
