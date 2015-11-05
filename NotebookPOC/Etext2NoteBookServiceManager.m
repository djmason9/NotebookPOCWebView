//
//  Etext2NoteBookServiceManager.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 11/5/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2NoteBookServiceManager.h"


@implementation Etext2NoteBookServiceManager

+(void)getNotes:(NSString*)apiURL withHandler:(void (^)(NSArray*, NSError*))handler{
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(!connectionError){
            
            NSError *error;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *noteArray = responseObject[@"data"];
            
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

+(void)saveNote:(NSString*)apiURL bodyText:(NSString*)jsonString withHandler:(void (^)(NSString*, NSError*))handler{

//    //set up the body
    NSData *postdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postdata];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if(!connectionError){
            NSLog(@"%@",data);
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
