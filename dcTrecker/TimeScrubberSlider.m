//
//  TimeScrubberSlider.m
//  protoPlayer
//
//  Created by Douglas Carmichael on 2/5/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "TimeScrubberSlider.h"
#import "ViewController.h"

@implementation TimeScrubberSlider

@synthesize delegate;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)mouseDown:(NSEvent *)theEvent
{
    [delegate setDragTimeline:NO];
    [super mouseDown:theEvent];
    [self mouseUp:theEvent];
}


-(void)mouseUp:(NSEvent *)theEvent
{
    [delegate setModPosition:[self intValue]];
    [delegate setDragTimeline:YES];
}

@end
