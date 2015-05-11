//
//  xmpWriter.m
//  xmpWriterTest
//
//  Created by Douglas Carmichael on 1/18/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "xmpWriter.h"
#import "xmpWriterErrors.h"
#import "xmp.h"

@implementation xmpWriter

-(id)init
{
    self = [super init];
    if (self)
    {
        // Initialize our libxmp context
        writer_context = xmp_create_context();
        // Put the library version in a property
        _xmpVersion = [NSString stringWithUTF8String:xmp_version];
        
        // Put a list of our supported formats in an NSArray
        char **xmp_format_list;
        xmp_format_list = xmp_get_format_list();
        NSMutableArray *tempSupportedFormats = [[NSMutableArray alloc] init];
        for (int i = 0; i <= sizeof(xmp_format_list); i++)
        {
            [tempSupportedFormats addObject:[NSString stringWithUTF8String:xmp_format_list[i]]];
        }
        _supportedFormats = [tempSupportedFormats copy];
    }
    return self;
}

-(void)loadModule:(Module *)ourModule error:(NSError *__autoreleasing *)error
{
    if (xmp_load_module(writer_context, (char *)[[ourModule filePath].path UTF8String]) != 0)
    {
        if (error != NULL)
        {
            NSString *errorDescription = NSLocalizedString(@"Cannot load module.", @"");
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSString *xmpErrorDomain = @"net.dcarmichael.xmpWriter";
            *error = [NSError errorWithDomain:xmpErrorDomain code:xmpLoadingError userInfo:errorInfo];
            return;
        }
    }
    return;
}

-(void)writeModuleWAV:(NSURL *)moduleWritePath error:(NSError *__autoreleasing *)error
{
    // Set up some structures we're going to need
    struct xmp_frame_info writer_info;
    UInt32 frame_size;
    AudioStreamBasicDescription inputFormat = {};
    AudioChannelLayout inputLayout = {};
    AudioBufferList writeModBuffer = {};
    ExtAudioFileRef writeModRef = NULL;
    
    // Set up our status variables
    int status;
    OSStatus err;
    
    // Do we have a module loaded?
    status = xmp_get_player(writer_context, XMP_PLAYER_STATE);
    if (status == XMP_STATE_UNLOADED)
    {
        if (error != NULL)
        {
            NSString *errorDescription = NSLocalizedString(@"No module loaded.", @"");
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSString *xmpErrorDomain = @"net.dcarmichael.xmpWriter";
            *error = [NSError errorWithDomain:xmpErrorDomain code:xmpLoadingError userInfo:errorInfo];
            return;
        }
    }
    
    // Set up our ASBD and layout (44.1kHz 16-bit stereo)
    inputFormat.mSampleRate = 44100;
    inputFormat.mFormatID = kAudioFormatLinearPCM;
    inputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    inputFormat.mChannelsPerFrame = 2;
    inputFormat.mFramesPerPacket = 1;
    inputFormat.mBitsPerChannel = 16;
    inputFormat.mBytesPerFrame = 4;
    inputFormat.mBytesPerPacket = 4;
    inputLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    // Set up our audio buffer list
    writeModBuffer.mNumberBuffers = 1;
    
    // Create our audio file (44.1kHz 16-bit stereo WAV)
    // NOTE: Audio Converter Services will be required to convert audio into other formats
    
    // Create our audio file
    err = ExtAudioFileCreateWithURL((__bridge CFURLRef)(moduleWritePath), kAudioFileWAVEType,
                                    &inputFormat, &inputLayout, kAudioFileFlags_EraseFile, &writeModRef);
    if(err != noErr)
    {
        if (error != NULL)
        {
            NSString *errorDescription = NSLocalizedString(@"Error creating audio file.", @"");
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSString *xmpErrorDomain = @"net.dcarmichael.xmpWriter";
            *error = [NSError errorWithDomain:xmpErrorDomain code:err userInfo:errorInfo];
            return;
        }
    }
    
    // If we've succeeded, set our error value to nil
    if (error != NULL)
    {
        *error = nil;
    }
    
    // Start playback
    status = xmp_start_player(writer_context, inputFormat.mSampleRate, 0);
    
    do
    {
        xmp_get_frame_info(writer_context, &writer_info);
        if (writer_info.loop_count > 0)
            break;
        
        writeModBuffer.mBuffers[0].mDataByteSize = writer_info.buffer_size;
        writeModBuffer.mBuffers[0].mNumberChannels = inputFormat.mChannelsPerFrame;
        writeModBuffer.mBuffers[0].mData = writer_info.buffer;
        
        frame_size = writer_info.buffer_size / inputFormat.mBytesPerFrame;
        
        err = ExtAudioFileWrite(writeModRef, frame_size, &writeModBuffer);
        
    } while (xmp_play_frame(writer_context) == 0);
    
    // Dispose of the file and end module playback
    ExtAudioFileDispose(writeModRef);
    xmp_end_player(writer_context);
}

-(void)dealloc
{
    xmp_free_context(writer_context);
}
@end
