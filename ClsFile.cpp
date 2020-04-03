#include "./ClsFile.h"

ClsFile::ClsFile(std::string filePath, std::string nFileName)
{
    std::ifstream t(filePath);
    this->fileBuffer << t.rdbuf();
    fileString = fileBuffer.str();
    this->fileName = nFileName;
    this->endpoint = new RestEndpoint(fileString, fileName);
}