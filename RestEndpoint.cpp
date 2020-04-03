#include "RestEndpoint.h"
#include "TextUtils.h"

void RestEndpoint::populateAddress()
{
    address = getSymbolBetweenAfter(*fs, 0, "='", ")");
}

void RestEndpoint::populateEndpoints()
{
    for (int i = 1; i < 6; i++)
    {
        if (mapToIndex.find(tags[i]) != mapToIndex.end())
        {
            rest_endpoint endpoint;
            std::string httpMethod = tags[i];
            removeStringFromString(httpMethod, "@Http");
            endpoint.httpMethod = httpMethod;
            endpoint.method = getTagMethod(mapToIndex[tags[i]]);
            endpoint.description = getTagComment(mapToIndex[tags[i]]);
            endpoints.push_back(endpoint);
        }
    }
}

std::string RestEndpoint::getTagMethod(int tagIndex)
{
    return getSymbolBetweenAfter(*fs, tagIndex, " ", "(");
}

std::string RestEndpoint::getTagComment(int tagIndex)
{

    std::string rawComment = getSymbolBetweenBefore(*fs, tagIndex, "/**", "*/");
    removeStringFromString(rawComment, "* ");
    removeStringFromString(rawComment, "  ");

    return rawComment;
}

void RestEndpoint::setTagsIndex()
{
    for (int i = 0; i < fs->length(); i++)
    {
        if (fs->at(i) == '@') // If we are at the start of a tags
        {
            for (std::string tag : tags) // Iterate over the array of tags
            {
                if (fs->substr(i, tag.length()) == tag) // If we match one
                {
                    mapToIndex.insert(std::pair(tag, i)); // Add its index to the map
                }
            }
        }
    }
    if (mapToIndex.find(tags[0]) != mapToIndex.end()) // If we found the address tag
    {
        isEndpoint = true; // Then we expect this to be an endpont
    }
}

void RestEndpoint::print()
{
    std::cout << "============================" << std::endl;
    std::cout << "FILE: " << filename << std::endl;
    std::cout << "ENDPOINT: " << address << std::endl;

    std::cout << "\nMETHODS:" << std::endl;
    for (rest_endpoint &endpoint : endpoints)
    {
        std::cout << "HTTP Method: " << endpoint.httpMethod << std::endl;
        std::cout << "Method: " << endpoint.method << std::endl;
        std::cout << "Description: " << endpoint.description << std::endl;
    }
}

RestEndpoint::RestEndpoint(std::string &file, std::string &fileName)
{
    isEndpoint = false;
    fs = &file;
    filename = fileName.substr(0, fileName.length() - 4);

    setTagsIndex();

    if (isEndpoint)
    {
        populateEndpoints();
        populateAddress();
    }
}