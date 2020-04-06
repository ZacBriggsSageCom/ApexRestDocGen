#include "./TextUtils.h"

std::string getSymbolBetweenAfter(std::string &input, int searchFromIndex, std::string matchStart, std::string matchEnd)
{
    int indexStart = 0;
    int indexEnd = 0;
    for (int i = searchFromIndex; input.substr(i, matchEnd.length()) != matchEnd; i++)
    {
        indexEnd = i + 1;

        if (input.substr(i, matchStart.length()) == matchStart)
        {
            indexStart = i + matchStart.length();
        }
    }
    return input.substr(indexStart, indexEnd - indexStart);
}

// Works by finding the beginning of sequence occuring before the searchFromIndex
// And then performing a forward search from that point.
std::string getSymbolBetweenBefore(std::string &input, int searchFromIndex, std::string matchStart, std::string matchEnd)
{
    int indexStart = 0;

    for (int i = searchFromIndex; input.substr(i, matchStart.length()) != matchStart; i--)
    {
        indexStart = i - matchStart.length();

        if (input.at(i) == '}' || input.at(i) == '{')
        { // There was no comment before previous function begins
            return "No doc comment found\n";
        }
    }
    return getSymbolBetweenAfter(input, indexStart, matchStart, matchEnd);
}

void removeStringFromString(std::string &input, std::string remove)
{
    size_t index = 0;
    while (true)
    {
        index = input.find(remove, index);
        if (index == std::string::npos)
        {
            break;
        }
        input.replace(index, remove.length(), "");
    }
}

void replaceStringInString(std::string &input, std::string match, std::string replace)
{
    size_t index = 0;
    while (true)
    {
        index = input.find(match, index);
        if (index == std::string::npos)
        {
            break;
        }

        input.replace(index, match.length(), replace);
        index += replace.length();
    }
}
void escapeWildcards(std::string &str)
{
    size_t index = 0;
    while (true)
    {
        index = str.find("/*", index);
        if (index == std::string::npos)
        {
            break;
        }

        str.replace(index, 2, "/\\*");
        index += 2;
    }
}