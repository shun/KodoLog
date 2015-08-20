//
//  LogStore.cpp
//  KodoLog
//
//  Created by KudoShunsuke on 8/20/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

#include <fstream>
#include <string>
#include <iostream>
#include "LogStore.h"
#include "Utility.h"

LogStore::LogStore() {
    m_logs.clear();
}

LogStore::~LogStore() {
    m_logs.clear();
}

bool LogStore::load(const char*path) {
    int latidx, lngidx, timestampidx, stepsidx;
    std::string lastlat, lastlng, lasttimestamp, laststeps;
    std::ifstream ifs(path);
    std::string line;

    latidx = lngidx = timestampidx = stepsidx = -1;
    lastlat = lastlng = lasttimestamp = laststeps = "";

    if (ifs.fail()) {
        return false;
    }

    std::vector<std::string>items;
    int64_t lineno = 0;
    while (getline(ifs, line)) {
        lineno++;
        items.clear();
        split(line, ',', items);

        if ("Time" == items.at(0)) {
            for (int i = 0; i < items.size(); i++) {
                if (items.at(i) == "Latitude") {
                    latidx = i;
                }
                else if (items.at(i) == "Longitude") {
                    lngidx = i;
                }
                else if (items.at(i) == "GPS Time") {
                    timestampidx = i;
                }
                else if (items.at(i) == "Steps") {
                    timestampidx = i;
                }
            }
            continue;
        }
        else {
            if ((lastlat == items.at(latidx)) && (lastlng == items.at(lngidx))) {
                continue;
            }
            lastlat = items.at(latidx);
            lastlng = items.at(lngidx);
            m_logs.push_back(line);
        }
    }

    std::cout << "count : " << lineno << "(" << m_logs.size() << ")" << std::endl;
    return true;
}

const char* LogStore::at(const unsigned int idx) {
    return nullptr;
}