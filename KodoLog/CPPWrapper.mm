//
//  CPPWrapper.m
//  KodoLog
//
//  Created by KudoShunsuke on 8/21/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

#import "CPPWrapper.h"
#import "LogStore.h"

@implementation CPPWrapper {
    LogStore *m_logstore;
}

-(id)init {
    self = [super init];
    m_logstore = new LogStore();
    return self;
}

-(void)dealloc {
    delete m_logstore;
}

-(BOOL)load:(NSString*)path {
    return m_logstore->load([path UTF8String]);
}

-(NSString*)getLine:(int)index {
    return [NSString stringWithCString:m_logstore->at(index) encoding:NSUTF8StringEncoding];
}

@end
