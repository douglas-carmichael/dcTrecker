//
//  LibraryManager.h
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
    NSMutableArray *libraryArray;
}

+(id)sharedLibrary;
-(void)clearLibrary:(BOOL)clearCurrentProperty;
-(BOOL)saveLibrary:(NSURL *)myPlaylist;
-(BOOL)loadLibrary:(NSURL *)myPlaylist;
-(BOOL)checkForTags:(NSXMLDocument *)ourDocument XPathToCheck:(NSString *)tagPath;
-(BOOL)addModule:(Module *)moduleToAdd;
-(void)removeModuleAtIndex:(NSInteger)ourRow;
-(Module *)getModuleAtIndex:(NSInteger)ourRow;
-(NSString *)getModuleLength:(NSInteger)ourRow;
-(NSInteger)libraryCount;
-(BOOL)isEmpty;

@property (readonly) NSURL *currentLibrary;

@end
