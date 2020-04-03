#ifndef CLSFILE_H
#define CLSFILE_H

#include <fstream>
#include <string>
#include <sstream>
#include "./RestEndpoint.h"

class ClsFile
{
public:
    std::stringstream fileBuffer;
    std::string fileString;
    std::string fileName;
    RestEndpoint *endpoint;

    explicit ClsFile(std::string filePath, std::string nFileName);
};

#endif