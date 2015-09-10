//
//  Utility.h
//  KodoLog
//
//  Created by KudoShunsuke on 8/21/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

#ifndef KodoLog_Utility_h
#define KodoLog_Utility_h

#include <vector>
#include <string>
#include <sstream>
#include <time.h>

unsigned long split(const std::string& line, char delimiter, std::vector<std::string>&elements) {

    std::istringstream stream(line);
    std::string field;

    while (std::getline(stream, field, delimiter)) {
        elements.push_back(field);
    }
    return elements.size();
}

time_t cnvDateTimeToEpoch(const std::string &datetime, const std::string &format) {
    return cnvDateTimeToEpoch(datetime.c_str(), format.c_str());
}

time_t cnvDateTimeToEpoch(const char *datetime, const char *format) {
    time_t epochsec = -1;
    struct tm tm;

    if (strptime(datetime, format, &tm) == nullptr) {
        return epochsec;
    }

    epochsec = mktime(&tm);
    return epochsec;
}

std::string cnvEpochToDateTime(time_t epochsec, const char * format) {
    const int bufsize = 30;
    char datetime[bufsize];
    struct tm * tm = localtime(&epochsec);
    strftime(datetime, bufsize, format, tm);
    return std::string(datetime);
}
#endif
