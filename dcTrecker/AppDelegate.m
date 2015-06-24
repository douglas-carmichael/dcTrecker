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
    ourLibrary = [LibraryManager sharedLibrary];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)newLibrary:(id)sender
{
    [ourLibrary clearLibrary:YES];
    NSString *notificationName = @"dcT_reloadLibrary";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)openLibrary:(id)sender
{
    NSString *notificationName = @"dcT_openLibraryMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)openModule:(id)sender
{
    [self newLibrary:nil];
    [self addModule:nil];
}

-(IBAction)saveLibrary:(id)sender
{
    NSString *notificationName = @"dcT_saveLibraryMenu";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(IBAction)saveAsLibrary:(id)sender
{
    NSString *notificationName = @"dcT_saveAsLibraryMenu";
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
    NSString *notificationName = @"dcT_removeLibrary";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    if ([[filename pathExtension] isEqual: @"xml"])
    {
        [ourLibrary clearLibrary:YES];
        BOOL loadSuccess = [ourLibrary loadLibrary:[NSURL fileURLWithPath:filename]];
        if (loadSuccess == NO)
        {
            return NO;
        }
        
        // Reload the library
        NSString *notificationName = @"dcT_reloadLibrary";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        return YES;
    }
    
    // If this isn't an XML library, treat it as a module
    Module *droppedModule = [[Module alloc] init];
    [droppedModule setFilePath:[NSURL fileURLWithPath:filename]];
    BOOL addSuccess = [ourLibrary addModule:droppedModule];
    if (addSuccess == YES)
    {
        
        // Reload the library
        NSString *notificationName = @"dcT_reloadLibrary";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        return YES;
    }
    return NO;
};

@end
