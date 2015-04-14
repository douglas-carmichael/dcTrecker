//
//  ViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "xmpPlayer.h"
#import "Module.h"

xmpPlayer *ourPlayer;
Module *ourModule;

@interface ViewController : NSViewController
{
    IBOutlet NSTextField *moduleName;
    IBOutlet NSTextField *moduleTime;
    IBOutlet NSTextField *modulePosition;
}

-(IBAction)openPlaylist:(id)sender;
-(IBAction)savePlaylist:(id)sender;

@end

