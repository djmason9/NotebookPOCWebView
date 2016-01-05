//
//  Etext2NoteBookServiceManager.h
//  NotebookPOC
//
//  Created by Mason, Darren J on 11/5/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: remove these in merge
#define SERVER_DEVLOPMENT @"DEVELOPMENT"
#define SERVER_STAGE @"PPE"
#define SERVER_PROD @"PRODUCTION"


#define BOOK_ID @"786856f8-be28-4083-9099-6c6eda8a29eb"
#define PAGE_ID @"6cd7611c-1e8b-4959-843c-78ebb844abc7"
#define USER_ID @"demoUser"

#define AUTH_TOKEN @"Bearer jPPnPE2bEYnZ40AHDB4ajtSquQDV"



@interface Etext2NoteBookServiceManager : NSObject

+(void)getPagesForBook:(NSString*)apiURL withHandler:(void (^)(NSArray*, NSError*))handler;
+(void)getPagesForBook:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSString*, NSError*))handler;

+(void)getBookIdByAppId:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSString*, NSError*))handler;
+(void)saveNote:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSDictionary*, NSError*))handler;
+(void)getNotes:(NSString*)apiURL withHandler:(void (^)(NSArray*, NSError*))handler;
+(void)deleteNote:(NSString*)apiURL withHandler:(void (^)(NSString*, NSError*))handler;

+(void)getAllNotes:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSDictionary*,NSError*))handler;

+(void)getAllNotesPrompts:(NSString*)apiURL withHandler:(void (^)(NSDictionary*,NSError*))handler;

@end
