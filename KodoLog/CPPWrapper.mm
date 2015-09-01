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

-(void)clear {
    m_logstore->clear();
}

-(NSArray *)getItems {
    NSMutableArray * array = [NSMutableArray array];

    unsigned long size = m_logstore->count();

    for (int i = 0; i < size; i++) {
        S_STOREITEMS items = m_logstore->at(i);
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: @(items.latitude), @"latitude",
                                                                        @(items.longitude), @"longitude",
                                                                        @(items.haccuracy), @"haccuracy",
                                                                        @(items.vaccuracy), @"vaccuracy",
                                                                        nil];
        [array addObject: dic];
    }
    return array;
}
@end
