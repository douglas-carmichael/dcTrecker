//
//  MenuResponder.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/14/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "MenuResponder.h"

@implementation MenuResponder

- (id)init
{
    self = [super init];
    if (self) {
        ourPlaylist = [PlaylistManager sharedPlaylist];
    }
    return self;
}
-(IBAction)newPlaylist:(id)sender
{
    [ourPlaylist clearPlaylist];
    NSString *notificationName = @"dcT_ReloadPlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)openDocument:(id)sender
{
    NSLog(@"openDocument");
}

-(IBAction)saveDocument:(id)sender
{
    NSLog(@"saveDocument");
}

-(IBAction)saveDocumentAs:(id)sender
{
    NSLog(@"saveDocumentAs");
}

@end
