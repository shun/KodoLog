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

unsigned long split(const std::string line, char delimiter, std::vector<std::string>&elements) {

    std::istringstream stream(line);
    std::string field;

    while (std::getline(stream, field, delimiter)) {
        elements.push_back(field);
    }
    return elements.size();
}
#endif
