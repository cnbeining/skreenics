/******************************************************************************
 * $Id: NSStringAdditions.m 9140 2009-09-18 03:49:55Z livings124 $
 *
 * Copyright (c) 2005-2009 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#import "NSStringAdditions.h"


@implementation NSString (NSStringAdditions)

+ (NSString *)stringForFileSize:(uint64_t) size
{
    if (size < 1024)
    {
        if (size != 1)
        {
            return [NSString stringWithFormat: @"%lld %@", size, @"bytes"];
        }
        else
        {
            return @"1 byte";
        }
    }
    
    CGFloat     convertedSize;
    NSString*   unit;

    if (size < pow(1024, 2))
    {
        convertedSize = size / 1024.0f;
        unit = @"KB";
    }
    else if (size < pow(1024, 3))
    {
        convertedSize = size / powf(1024.0f, 2.0f);
        unit = @"MB";
    }
    else if (size < pow(1024, 4))
    {
        convertedSize = size / powf(1024.0f, 3.0f);
        unit = @"GB";
    }
    else
    {
        convertedSize = size / powf(1024.0f, 4.0f);
        unit = @"TB";
    }
    
    //attempt to have minimum of 3 digits with at least 1 decimal
    return convertedSize <= 9.995f ? [NSString localizedStringWithFormat: @"%.2f %@", convertedSize, unit]
    : [NSString localizedStringWithFormat: @"%.1f %@", convertedSize, unit];
}

@end
