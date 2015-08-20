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
#include <vector>

class LogStore {
public :
    LogStore();
    ~LogStore();
    bool load(const char *path);
    const char*at(const unsigned int idx);

private :
    std::vector<std::string>m_logs;
};
#endif
