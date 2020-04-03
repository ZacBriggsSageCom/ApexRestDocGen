#ifndef FILEUTILS_H
#define FILEUTILS_H

#include <list>
#include <algorithm>
#include <string>
#include <filesystem>
#include "./RestEndpoint.h"
#include "./ClsFile.h"

#include <fstream>

namespace fs = std::filesystem;

void clsProjectParser(std::string directoryPath, std::list<RestEndpoint> &endpointsOut);

void escapeWildcards(std::string &str);

void convertToMarkdown(std::list<RestEndpoint> endpoints, std::string &markdownOut);

#endif