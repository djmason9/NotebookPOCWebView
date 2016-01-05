//
//  Etext2NoteBookServiceManager.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 11/5/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2NoteBookServiceManager.h"



@implementation Etext2NoteBookServiceManager

#pragma mark - getters
+(void)getPagesForBook:(NSString*)apiURL withHandler:(void (^)(NSArray*, NSError*))handler{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            
            NSError *error;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *noteArray = responseObject[@"data"];
            
            //            NSLog(@"RETURN %@",noteArray);
            handler(noteArray,nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
    
}

+(void)getPagesForBook:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSString*, NSError*))handler{
    
    NSData *postdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            
            NSError *error;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSString *pageId = responseObject[@"data"];
            
            handler(pageId,nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
}

+(void)getAllNotes:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSDictionary*,NSError*))handler{
    
    NSData *postdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            
            NSError *error;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSDictionary *dataDict = responseObject[@"data"];
            
            handler(dataDict,nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
    
}

+(void)getBookIdByAppId:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSString*, NSError*))handler{
    
    //    //set up the body
    NSData *postdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            handler(responseDict[@"data"],nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
    
}

+(void)getNotes:(NSString*)apiURL withHandler:(void (^)(NSArray*, NSError*))handler{
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        if(!connectionError){
            
            NSError *error;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSArray *noteArray = responseObject[@"data"];
            
            if([responseObject[@"code"] isEqualToNumber:@(404)] ||
               noteArray.count <= 0){
                handler([NSArray new],nil);
                return;
            }
            
            
            
            //sort by date
            NSSortDescriptor *sortType = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortType];
            //sorted Array
            noteArray = [[noteArray sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
            
            handler(noteArray,nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
}

#pragma mark - modifiers
+(void)saveNote:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSDictionary*, NSError*))handler{
    
    //    //set up the body
    NSData *postdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            //            NSLog(@"%@",data);
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            handler(responseDict,nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
}
+(void)getAllNotesPrompts:(NSString*)apiURL withHandler:(void (^)(NSDictionary*,NSError*))handler{

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"notebook" forHTTPHeaderField:@"application-id"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            handler(responseDict,nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];

}
+(void)deleteNote:(NSString*)apiURL withHandler:(void (^)(NSString*, NSError*))handler{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPMethod:@"DELETE"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            //            NSLog(@"%@",data);
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            handler(responseDict[@"status"],nil);
        }else{
            NSLog(@"%@",[connectionError description]);
            handler(nil,connectionError);
        }
        
    }];
}




@end
