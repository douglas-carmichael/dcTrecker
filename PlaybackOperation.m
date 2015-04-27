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

-(id)initWithModule:(Module *)myModule
{
    self = [super init];
    ourPlayer = [[xmpPlayer alloc] init];
    [ourPlayer loadModule:myModule error:nil];
    return self;
};

-(void)main
{
    [ourPlayer playModule:nil];
}

@end
