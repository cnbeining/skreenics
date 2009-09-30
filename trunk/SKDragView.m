//
//  SKDragView.m
//  Skreenics
//
//  Created by naixn on 12/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <QTKit/QTKit.h>

#import "SKDragView.h"


@implementation SKDragView

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
        acceptableMovieTypes = [[QTMovie movieTypesWithOptions:QTIncludeCommonTypes] retain];
    }
    return self;
}

- (void)dealloc
{
    [acceptableMovieTypes release];
    [super dealloc];
}

- (void)setDragDelegate:(id <SKDragDelegateProtocol>)delegate
{
    dragDelegate = delegate;
}

#pragma mark Drag and Drop Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSWorkspace*    workspace;
    NSFileManager*  filemanager;
    NSPasteboard*   pboard;
    NSDragOperation sourceDragMask;
    BOOL            canQTKitInitDraggedFiles;
    BOOL            pathIsDirectory;

    // Init some variables
    workspace = [NSWorkspace sharedWorkspace];
    filemanager = [NSFileManager defaultManager];
    pboard = [sender draggingPasteboard];
    sourceDragMask = [sender draggingSourceOperationMask];
    canQTKitInitDraggedFiles = NO;
    pathIsDirectory = NO;

    // We accept data from pasteboard only if it contains filenames
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        // Look if we have at least one type of file we can deal with (movie / folder)
        for (NSString* filePath in [pboard propertyListForType:NSFilenamesPboardType])
        {
            [filemanager fileExistsAtPath:filePath isDirectory:&pathIsDirectory];
            if (pathIsDirectory)
            {
                break;
            }
            if ([acceptableMovieTypes containsObject:[workspace typeOfFile:filePath error:nil]])
            {
                canQTKitInitDraggedFiles = YES;
                break;
            }
        }
        // If a folder is dragged, of the filename list contains a movie, return "NSDragOperationCopy" to get the (+) icon
        if ((pathIsDirectory || canQTKitInitDraggedFiles) && (sourceDragMask & NSDragOperationCopy))
        {
            return NSDragOperationCopy;
        }
    }

    // If all of the above failed, then we can't handle anything that was dragged
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard*   pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType] )
    {
        for (NSString* filePath in [pboard propertyListForType:NSFilenamesPboardType])
        {
            [dragDelegate addDragPathElement:filePath];
        }
        return YES;
    }
    return NO;
}

@end
