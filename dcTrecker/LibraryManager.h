//
//  PlaylistManager.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Module.h"
#import "xmpPlayer.h"
#import "xmpWriter.h"

@interface LibraryManager : NSObject
{
    NSMutableArray *playlistArray;
}

+(id)sharedLibrary;
-(void)clearLibrary:(BOOL)clearCurrentProperty;
-(BOOL)savePlaylist:(NSURL *)myPlaylist;
-(BOOL)loadPlaylist:(NSURL *)myPlaylist;
-(BOOL)checkForTags:(NSXMLDocument *)ourDocument XPathToCheck:(NSString *)tagPath;
-(BOOL)addModule:(Module *)moduleToAdd;
-(void)removeModuleAtIndex:(NSInteger)ourRow;
-(Module *)getModuleAtIndex:(NSInteger)ourRow;
-(NSString *)getModuleLength:(NSInteger)ourRow;
-(NSInteger)playlistCount;
-(BOOL)isEmpty;

@property (readonly) NSURL *currentLibrary;

@end
