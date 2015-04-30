//
//  PlaybackOperation.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/26/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"
#import "xmpPlayer.h"

xmpPlayer *ourPlayer;
dispatch_group_t ourGroup;

@interface PlaybackOperation : NSOperation
{
    Module *ourModule;
    NSOperationQueue *ourQueue;
    
}


@property (retain) Module *ourModule;
@property (retain) NSOperationQueue *ourQueue;

-(id)initWithModule:(Module *)myModule modPlayer:(xmpPlayer *)myPlayer;
-(void)cancel;

@end
