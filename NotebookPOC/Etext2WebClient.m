//
//  Etext2WebClient.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/21/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2WebClient.h"

@implementation Etext2WebClient

+ (NSString *)getEndpointURLForKey:(NSString *)endpointKey
{
    // Get the URl from the Endpoints plist
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"EndPoints" ofType:@"plist"];
    NSDictionary *endPoints = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if( endPoints[endpointKey] == nil )
        return @"";
    
    return endPoints[endpointKey];
}

+ (NSDictionary*)dictionaryFromPlist:(NSString *)plistName
{
    NSRange range = [plistName rangeOfString:@".plist"];
    
    if ( range.length > 0 )
    {
        plistName = [plistName substringToIndex:range.location];
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    
    NSDictionary* propertyListValues = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    return propertyListValues;
}



@end
