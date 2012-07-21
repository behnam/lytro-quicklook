#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <stdio.h>

#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSError *fileError = nil;
    NSString *filePath = [url path];
    NSData *fileData = [NSData 
                            dataWithContentsOfFile:filePath 
                            options:NSDataReadingMapped 
                            error:&fileError];
    
    if( !fileData ) {
        NSLog(@"An error must have occurred: %@, %@", fileError, [fileError userInfo]);
    } else {
//        NSLog(@"The data length: %lu", (unsigned long)[fileData length]);
    }
    
    unsigned char head[8];
    [fileData getBytes:head length:8];
    if( memcmp( head, (unsigned char[]){ 0x89, 0x4C, 0x46, 0x50, 0x0D, 0x0A, 0x1A, 0x0A }, 8 ) != 0 )
    {
        return noErr;
    }
    
//    NSMutableData *jpeg;
    bool inJPEG = false;
    int jpegStart = 0;
    int jpegEnd = 0;
    for (int i = 0; i < [fileData length]; i++)
    {
        if (i+10 > [fileData length]) {
            return noErr;
        }
        
        unsigned char *byte[10];
        [fileData getBytes:&byte range:NSMakeRange(i, 10)];
        
        if (inJPEG && memcmp(byte, (unsigned char[]){ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, 10) == 0)
        {
            jpegEnd = i;
            break;
        }
        
        if (memcmp(byte, (unsigned char[]){ 0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46}, 10) == 0)
        {
            if (inJPEG) {
                jpegEnd = i;
                break;
            }
            
            inJPEG = true;
            jpegStart = i;
        }
    }
    
    NSData *jpeg;
    jpeg = [fileData subdataWithRange:NSMakeRange(jpegStart, jpegEnd-jpegStart)];    
    
    NSImage *originalImage = [[NSImage alloc] initWithData:jpeg];
    NSImage *previewImage = [[NSImage alloc] initWithSize: NSMakeSize(400, 400)];
    NSSize originalSize = [originalImage size];
    
    [previewImage lockFocus];
    [originalImage drawInRect: NSMakeRect(0, 0, 400, 400) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
    [previewImage unlockFocus];

    NSData *resizedData = [previewImage TIFFRepresentation];
    [originalImage release];
    [previewImage release];
    
    QLPreviewRequestSetDataRepresentation(preview,(CFDataRef)resizedData,kUTTypeImage,NULL);
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}