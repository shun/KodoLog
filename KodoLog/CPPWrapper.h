//
//  CPPWrapper.h
//  KodoLog
//
//  Created by KudoShunsuke on 8/21/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

#ifndef KodoLog_CPPWrapper_h
#define KodoLog_CPPWrapper_h
#import <Foundation/Foundation.h>

@interface CPPWrapper : NSObject
-(BOOL)load:(NSString*)path;
-(NSArray*)getItems;
-(NSDictionary*)getItem:(unsigned long)index;
-(void)clear;
-(unsigned long)getSize;
@end

#endif
