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
    NSLog(@"Module name: %@", [myModule moduleName]);
    [myPlayer loadModule:myModule error:nil];
    ourPlayer = myPlayer;
    return self;
};

-(void)main
{
    [ourPlayer playModule:nil];
}

-(void)cancel
{
    [ourPlayer stopPlayer];
}

@end
