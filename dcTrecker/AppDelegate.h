//
//  AppDelegate.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LibraryManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

{
    LibraryManager *ourLibrary;
}

-(IBAction)newLibrary:(id)sender;
-(IBAction)openLibrary:(id)sender;
-(IBAction)openModule:(id)sender;
-(IBAction)saveLibrary:(id)sender;
-(IBAction)saveAsLibrary:(id)sender;
-(IBAction)revertToSaved:(id)sender;

@end

