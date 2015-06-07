//
//  xmpWriterErrors.h
//  xmpWriterTest
//
//  Created by Douglas Carmichael on 1/18/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#ifndef xmpWriterTest_xmpWriterErrors_h
#define xmpWriterTest_xmpWriterErrors_h

extern NSString *xmpErrorDomain;

enum
{
    xmpInternalError,
    xmpPlaybackError,
    xmpInvalidError,
    xmpFormatError,
    xmpFileError,
    xmpLoadingError,
    xmpDepackError,
    xmpSystemError,
    xmpStateError
};

#endif
