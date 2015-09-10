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
    double lat, lng, hac, vac;
    long epochsec = 0;

    lat = lng = hac =  vac = 0.0;

    for (int i = 0; i < size; i++) {
        S_STOREITEMS items = m_logstore->at(i);
        lat = items.latitude;
        lng = items.longitude;
        hac = items.haccuracy;
        vac = items.vaccuracy;
        epochsec = items.epochsec;

        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: @(lat), @"latitude",
                                                                        @(lng), @"longitude",
                                                                        @(hac), @"haccuracy",
                                                                        @(vac), @"vaccuracy",
                                                                        @(epochsec), @"epochsec",
                                                                        nil];
        [array addObject: dic];
    }
    return array;
}

-(NSDictionary*)getItem:(unsigned long)index {
    unsigned long size = m_logstore->count();

    if (size < index) {
        return nil;
    }

    S_STOREITEMS items = m_logstore->at((unsigned int)index);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: @(items.latitude), @"latitude",
                         @(items.longitude), @"longitude",
                         @(items.haccuracy), @"haccuracy",
                         @(items.vaccuracy), @"vaccuracy",
                         [NSString stringWithCString:items.time.c_str() encoding:NSUTF8StringEncoding], @"time",
                         @(items.epochsec), @"epochsec",
                         nil];

    return dic;
}

-(unsigned long)getSize {
    return m_logstore->count();
}

@end
