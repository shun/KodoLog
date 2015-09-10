//
//  LogStore.cpp
//  KodoLog
//
//  Created by KudoShunsuke on 8/20/15.
//  Copyright (c) 2015 KudoShunsuke. All rights reserved.
//

#include <fstream>
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
    int latidx, lngidx, timestampidx, stepsidx, haccuracyidx, vaccuracyidx, timeidx;
    std::string lastlat, lastlng, lasttimestamp, laststeps;
    std::ifstream ifs(path);
    std::string line;

    latidx = lngidx = timestampidx = stepsidx = haccuracyidx = vaccuracyidx = timeidx = -1;
    lastlat = lastlng = lasttimestamp = laststeps = "";

    if (ifs.fail()) {
        return false;
    }

    m_logs.clear();

    std::vector<std::string>items;
    int64_t lineno = 0;
    S_STOREITEMS storeitems;
    std::string tmp = "";

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
                    stepsidx = i;
                }
                else if (items.at(i) == "HAccuracy") {
                    haccuracyidx = i;
                }
                else if (items.at(i) == "VAccuracy") {
                    vaccuracyidx = i;
                }
                else if (items.at(i) == "Time") {
                    timeidx = i;
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
            storeitems.latitude = atof(lastlat.c_str());
            storeitems.longitude = atof(lastlng.c_str());

            tmp = items.at(haccuracyidx);
            storeitems.haccuracy = atof(tmp.c_str());

            tmp = items.at(vaccuracyidx);
            storeitems.vaccuracy = atof(tmp.c_str());

            storeitems.time = items.at(timeidx);
            storeitems.epochsec = cnvDateTimeToEpoch(storeitems.time, "%Y-%m-%d %H:%M:%S");

            m_logs.push_back(storeitems);
        }
    }

    std::cout << "count : " << lineno << "(" << m_logs.size() << ")" << std::endl;
    return true;
}

const S_STOREITEMS LogStore::at(const unsigned int idx) {
    if (m_logs.size() < idx) {
        throw "Exception : beyond the index";
    }

    return m_logs.at(idx);
}