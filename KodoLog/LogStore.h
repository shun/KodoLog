//
//  LogStore.h
//  KodoLog
//
//  Created by KudoShunsuke on 8/20/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

#ifndef KodoLog_LogStore_h
#define KodoLog_LogStore_h

#include <stdint.h>
#include <string>
#include <vector>

enum {
    E_STOREITEMS_LAT = 0,
    E_STOREITEMS_LNG,
};

struct S_STOREITEMS {
    std::string time;
    double latitude;
    double longitude;
    double haccuracy;
    double vaccuracy;
};

class LogStore {
public :
    LogStore();
    ~LogStore();
    bool load(const char *path);
    const S_STOREITEMS at(const unsigned int idx);
    unsigned long count() { return m_logs.size(); }
    void clear() { m_logs.clear(); }
    

private :
    std::vector<S_STOREITEMS>m_logs;
};
#endif
