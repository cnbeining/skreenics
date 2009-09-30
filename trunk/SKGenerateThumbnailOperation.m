//
//  SKGenerateThumbnailOperation.m
//  Skreenics
//
//  Created by naixn on 13/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKGenerateThumbnailOperation.h"

#import "SKProgressIndicator.h"
#import "SKDefines.h"
#import "NSStringAdditions.h"

#define preferenceColorForKey(key) [[NSValueTransformer valueTransformerForName:@"SKRgbToNSColorTransformer"] transformedValue:[userDefaults valueForKey:key]]


@implementation SKGenerateThumbnailOperation

- (id)initWithVideoItem:(SKVideoItem *)aVideoItem
{
    if (self = [super init])
    {
        userDefaults = [NSUserDefaults standardUserDefaults];
        videoItem = [aVideoItem retain];
        rows = [userDefaults integerForKey:kSKNumberOfRowsPrefKey];
        cols = [userDefaults integerForKey:kSKNumberOfColumnsPrefKey];
    }
    return self;
}

- (void)dealloc
{
    [videoItem release];
    [super dealloc];
}

#pragma mark Attributed Strings Generation

- (NSAttributedString *)videoResolutionStringFromMovie:(QTMovie *)movie withAttributes:(NSDictionary *)stringAttributes
{
    NSSize      videoSize;
    NSString*   videoSizeFormat;

    videoSize = [[movie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
    videoSizeFormat = [NSString stringWithFormat:@"\n\tResolution: %.0fx%.0f", videoSize.width, videoSize.height];
    return [[[NSAttributedString alloc] initWithString:videoSizeFormat attributes:stringAttributes] autorelease];
}

- (NSAttributedString *)videoFileSizeStringFromMovie:(QTMovie *)movie withAttributes:(NSDictionary *)stringAttributes
{
    NSNumber*   videoFileSize;
    NSString*   videoFileSizeFormat;

    videoFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[movie attributeForKey:QTMovieFileNameAttribute] error:nil] objectForKey:NSFileSize];
    videoFileSizeFormat = [NSString stringWithFormat:@"\n\tFilesize: %@", [NSString stringForFileSize:[videoFileSize unsignedLongLongValue]]];
    return [[[NSAttributedString alloc] initWithString:videoFileSizeFormat attributes:stringAttributes] autorelease];
}

- (NSAttributedString *)detailsFromMovie:(QTMovie *)movie
{
    NSString*                   movieFilename;
    NSMutableDictionary*        stringAttributes;
    NSMutableAttributedString*  resultString;

    movieFilename = [[movie attributeForKey:QTMovieFileNameAttribute] lastPathComponent];

    // Setup shadow
    NSShadow* descriptionShadow = [[[NSShadow alloc] init] autorelease];
    [descriptionShadow setShadowOffset:NSMakeSize(1.75, -1.75)];
    [descriptionShadow setShadowColor:preferenceColorForKey(kSKImageShadowColorPrefKey)];
    [descriptionShadow setShadowBlurRadius:3.0];    

    // Create default attributes
    stringAttributes = [NSMutableDictionary dictionary];
    [stringAttributes setObject:[NSFont fontWithName:@"Arial Bold" size:20.0] forKey:NSFontAttributeName];
    [stringAttributes setObject:preferenceColorForKey(kSKImageMovieInfoColorPrefKey) forKey:NSForegroundColorAttributeName];
    [stringAttributes setObject:descriptionShadow forKey:NSShadowAttributeName];

    // Init the result with the filename
    resultString = [[NSMutableAttributedString alloc] initWithString:movieFilename attributes:stringAttributes];

    // Change attributes for "sub"-info
    [stringAttributes removeObjectForKey:NSShadowAttributeName];
    [stringAttributes setObject:[NSFont fontWithName:@"Arial Bold" size:15.0] forKey:NSFontAttributeName];

    // Add video resolution
    [resultString appendAttributedString:[self videoResolutionStringFromMovie:movie withAttributes:stringAttributes]];
    // Add file size
    [resultString appendAttributedString:[self videoFileSizeStringFromMovie:movie withAttributes:stringAttributes]];

    // Return the final string
    return [resultString autorelease];
}

- (NSAttributedString *)attributedStringForQTTime:(QTTime)time
{
    NSString*               timeString;
    NSMutableDictionary*    stringAttributes;

    // Convert the time into a string, and ommit some non-interesting data
    timeString = [QTStringFromTime(time) substringWithRange:NSMakeRange(2, 8)];

    // Setup string attributes
    stringAttributes = [NSMutableDictionary dictionary];
    [stringAttributes setObject:[NSFont fontWithName:@"Arial Bold" size:18.0] forKey:NSFontAttributeName];
    [stringAttributes setObject:[NSColor colorWithCalibratedWhite:1.0 alpha:0.75] forKey:NSForegroundColorAttributeName];
    [stringAttributes setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.75] forKey:NSStrokeColorAttributeName];
    [stringAttributes setObject:[NSNumber numberWithFloat:-5.0] forKey:NSStrokeWidthAttributeName];

    return [[[NSAttributedString alloc] initWithString:timeString attributes:stringAttributes] autorelease];
}

#define PREF_WIDTH [userDefaults floatForKey:kSKImageFileWidthPrefKey]
#define PREF_SPACING [userDefaults floatForKey:kSKSpacingBetweenThumbnailsPrefKey]
#define PREF_SAVEPATH @"/Users/naixn/Desktop/"
#define PREF_MOVIEINFO YES

- (void)main
{
    QTMovie*    movie;
    NSString*   movieFilePath;
    NSSize      movieSize;
    NSSize      imageSize;
    NSRect      imageRect;
    NSImage*    resultImage;
    NSImage*    currentFrameImage;
    NSSize      frameAreaSize;
    QTTime      incrementTime;
    QTTime      currentTime;
    NSString*   savePath;
    int         col;
    int         row;

    // Make sure QTKit is init on this thread
    [QTMovie enterQTKitOnThread];

    [videoItem setNumberOfSteps:[NSNumber numberWithUnsignedInteger:(5 + cols * rows)]];

    // ----------- Step 0: Init movie
    [videoItem setProgressString:@"Opening movie..." incrementProgressValue:NO];
    movieFilePath = [videoItem filepath];
    NSDictionary* openAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    movieFilePath,                  QTMovieFileNameAttribute,
                                    [NSNumber numberWithBool:NO],   QTMovieOpenAsyncOKAttribute,
                                    nil];
    movie = [[QTMovie alloc] initWithAttributes:openAttributes error:nil];

    // ----------- Step 1: Check if the movie actually has a movie track
    [videoItem setProgressString:@"Checking if file has a movie track..." incrementProgressValue:YES];
    if ([[movie tracksOfMediaType:QTMediaTypeVideo] count] == 0)
    {
        [videoItem setError:@"File does not contain a video track"];
        [movie release];
        [QTMovie exitQTKitOnThread];
        return ;
    }

    // ----------- Step 2: Init some other values
    [videoItem setProgressString:@"Preparing..." incrementProgressValue:YES];

    // Init some other values
    movieSize = [(NSValue *)[movie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
    frameAreaSize.width = (PREF_WIDTH - ((cols + 1) * PREF_SPACING)) / cols;
    frameAreaSize.height = (movieSize.height * frameAreaSize.width) / movieSize.width;
    imageSize = NSMakeSize(PREF_WIDTH, frameAreaSize.height * rows + (rows + 1) * PREF_SPACING);

    // Get the time we will pad around the movie, and set the initial value
    incrementTime = [movie duration];
    incrementTime.timeValue /= (long long)(cols * rows);
    currentTime = incrementTime;
    currentTime.timeValue /= 2.0;

    // If we need to display some movie details, we need to generate the
    // attributed string and add its size to the result image size
    NSAttributedString* movieDetails = nil;
    NSRect movieDetailsRectOrigin;
    if (PREF_MOVIEINFO)
    {
        movieDetails = [self detailsFromMovie:movie];
        movieDetailsRectOrigin = [movieDetails boundingRectWithSize:NSZeroSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingDisableScreenFontSubstitution)];
        imageSize.height += movieDetailsRectOrigin.size.height + PREF_SPACING;
    }

    // ----------- Step 3: create original image
    [videoItem setProgressString:@"Creating initial image..." incrementProgressValue:YES];

    // Allocate the image in which we will draw, erase everything, and set ready to draw
    resultImage = [[NSImage alloc] initWithSize:imageSize];
    [resultImage recache];
    [resultImage lockFocus];

    // Draw background
    [preferenceColorForKey(kSKImageBackgroundColorPrefKey) set];
    imageRect.origin = NSZeroPoint;
    imageRect.size = imageSize;
    [NSBezierPath fillRect:imageRect];
    [NSBezierPath setDefaultLineWidth:1.5];

    // Draw movie info
    if (PREF_MOVIEINFO && movieDetails)
    {
        [movieDetails drawAtPoint:NSMakePoint(PREF_SPACING, imageSize.height - PREF_SPACING - movieDetailsRectOrigin.size.height)];
    }

    // Setup the shadow
    NSShadow* thumbnailShadow = [[NSShadow alloc] init];
    [thumbnailShadow setShadowOffset:NSMakeSize(2.0, -2.0)];
    [thumbnailShadow setShadowColor:preferenceColorForKey(kSKImageShadowColorPrefKey)];
    [thumbnailShadow setShadowBlurRadius:3.0];

    for (row = 0; row < rows; row++)
    {
        for (col = 0; col < cols; col++)
        {
            // ----------- Step 4: create thumbnail
            [videoItem setProgressString:[NSString stringWithFormat:@"Processing frame %d of %d...", (int)((row * cols) + col) + 1, (int)(rows * cols)]
                  incrementProgressValue:YES];

            // Get current frame image, and compute frame position
            currentFrameImage = [movie frameImageAtTime:currentTime];
            CGFloat x = (col * frameAreaSize.width) + ((col + 1) * PREF_SPACING);
            CGFloat y = ((rows - row - 1) * frameAreaSize.height) + ((rows - row) * PREF_SPACING);

            // Draw frame image
            [NSGraphicsContext saveGraphicsState];
            [thumbnailShadow set];
            NSRect drawingRect = NSMakeRect(x, y, frameAreaSize.width, frameAreaSize.height);
            NSRect sourceRect = NSMakeRect(0, 0, [currentFrameImage size].width, [currentFrameImage size].height);
            [currentFrameImage drawInRect:drawingRect fromRect:sourceRect operation:NSCompositeCopy fraction:1.0];
            [NSGraphicsContext restoreGraphicsState];

            // Draw border
            [[[NSColor blackColor] colorWithAlphaComponent:0.75] set];
            [NSBezierPath strokeRect:drawingRect];

            // Draw timestamp
            [[self attributedStringForQTTime:currentTime] drawAtPoint:NSMakePoint(x + 5.0, y + 5.0)];

            // Get further in the video
            currentTime = QTTimeIncrement(currentTime, incrementTime);
        }
    }

    // We are done drawing on the image
    [resultImage unlockFocus];

    // ----------- Step 5: Write result to HD
    [videoItem setProgressString:@"Writing image..." incrementProgressValue:YES];

    // Write the result on the hard drive
    if ([userDefaults boolForKey:kSKPreferMovieFileFolderPrefKey])
    {
        savePath = [[movieFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    }
    else
    {
        NSString*   outputFolder = [[userDefaults objectForKey:kSKOuputFolderPrefKey] stringByExpandingTildeInPath];
        NSString*   outputFileName = [[[videoItem filename] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        savePath = [outputFolder stringByAppendingPathComponent:outputFileName];
    }
    NSBitmapImageRep* repr = [NSBitmapImageRep imageRepWithData:[resultImage TIFFRepresentation]];
    [[repr representationUsingType:NSPNGFileType properties:nil] writeToFile:savePath atomically:YES];

    // Release all our manually allocated data
    [thumbnailShadow release];
    [resultImage release];
    [movie release];

    [QTMovie exitQTKitOnThread];

    // ----------- Done
    [videoItem setProgressString:@"Done!" incrementProgressValue:YES];
}

@end
