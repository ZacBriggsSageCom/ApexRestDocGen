#ifndef COMMANDLINEPARSER_H
#define COMMANDLINEPARSER_H

#include <iostream>
#include <string>
#include <string.h>
#include <list>
#include <filesystem>
#include "./FileUtils.h"
#include "./RestEndpoint.h"

namespace fs = std::filesystem;

void printHelpHeader();
void printHelpOptions();
void printHelpNotes();
void printHelp();
void commandLineParser(int argc, char **argv);

#endif