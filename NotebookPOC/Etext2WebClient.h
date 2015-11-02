//
//  Etext2WebClient.h
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/21/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Etext2WebClient : NSObject

+ (NSString *)getEndpointURLForKey:(NSString *)endpointKey;
+ (NSDictionary*)dictionaryFromPlist:(NSString *)plistName;

@end
