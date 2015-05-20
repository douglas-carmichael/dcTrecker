//
//  AppDelegate.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/6/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ourPlaylist = [PlaylistManager sharedPlaylist];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)newPlaylist:(id)sender
{
    [ourPlaylist clearPlaylist:YES];
    NSString *notificationName = @"dcT_reloadPlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)openPlaylist:(id)sender
{
    NSString *notificationName = @"dcT_openPlaylistMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)savePlaylist:(id)sender
{
    NSString *notificationName = @"dcT_savePlaylistMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)saveAsPlaylist:(id)sender
{
    NSString *notificationName = @"dcT_saveAsPlaylistMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)revertToSaved:(id)sender
{
    NSString *notificationName = @"dcT_revertToSavedMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)addModule:(id)sender
{
    NSString *notificationName = @"dcT_addModuleMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)removeModule:(id)sender
{
    NSString *notificationName = @"dcT_removePlaylist";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    NSLog(@"filename: %@", filename);
    Module *droppedModule = [[Module alloc] init];
    [droppedModule setFilePath:[NSURL fileURLWithPath:filename]];
    BOOL addSuccess = [ourPlaylist addModule:droppedModule];
    if (addSuccess == YES)
    {
        NSString *notificationName = @"dcT_reloadPlaylist";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        return YES;
    }
//    [ourPlaylist clearPlaylist:YES];
//    BOOL loadSuccess = [ourPlaylist loadPlaylist:[NSURL fileURLWithPath:filename]];
//    if (loadSuccess == NO)
//    {
//        return NO;
//    }
//    return YES;
    return NO;
};

@end
