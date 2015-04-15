//
//  PlaylistManager.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"
#import "xmp.h"

@interface PlaylistManager : NSObject
{
    NSMutableArray *playlistArray;
    Module *ourModule;
}

-(void)clearPlaylist;
-(void)addModule:(NSURL *)moduleURL;

@end
