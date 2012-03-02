#import "FileHelpers.h"

// To use this function, you pass it a file name, and it will construct 
// the full path for that file in the Documents directory.
NSString *pathInDocumentDirectory(NSString *fileName)
{
    // Get list of document directories in sandbox
    NSArray *documentDirectories = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // Append passed in file name to that directory, return it
    return [documentDirectory stringByAppendingPathComponent:fileName];
}