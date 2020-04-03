#ifndef TEXTUTILS_H
#define TEXTUTILS_H
#include <string>

std::string getSymbolBetweenAfter(std::string &input, int searchFromIndex, std::string matchStart, std::string matchEnd);
std::string getSymbolBetweenBefore(std::string &input, int searchFromIndex, std::string matchStart, std::string matchEnd);
void removeStringFromString(std::string &input, std::string remove);
void replaceStringInString(std::string &input, std::string match, std::string replace);
void escapeWildcards(std::string &str);

#endif