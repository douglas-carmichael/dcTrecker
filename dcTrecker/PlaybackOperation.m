//
//  PlaybackOperation.m
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/26/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "PlaybackOperation.h"

@implementation PlaybackOperation

@synthesize ourModule, ourQueue;

-(id)initWithModule:(Module *)myModule modPlayer:(xmpPlayer *)myPlayer
{
    self = [super init];
    NSString *ourModuleName = [myModule moduleName];
    NSDictionary *ourNameDict = [NSDictionary dictionaryWithObject:ourModuleName
                                                            forKey:@"currModName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dcT_setModuleName"
                                                        object:nil userInfo:ourNameDict];
    NSError *ourError = nil;
    
    [myPlayer loadModule:myModule error:&ourError];
    if (ourError)
    {
        NSString *ourFilePath = [[[myModule filePath] path] lastPathComponent];
        NSDictionary *ourPathDict = [NSDictionary dictionaryWithObject:ourFilePath
                                                                forKey:@"currFilePath"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dcT_cannotLoadMod"
                                                            object:nil userInfo:ourPathDict];
    }
    ourPlayer = myPlayer;
    return self;
};

-(void)main
{
    [ourPlayer playModule:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dcT_nextSong"
                                                        object:nil userInfo:nil];

}

-(void)cancel
{
    [ourPlayer stopPlayer];
}

@end
