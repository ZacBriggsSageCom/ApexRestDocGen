#include "RestEndpoint.h"

void RestEndpoint::populateAddress()
{
    int addIndex = mapToIndex[ADDRESS_TAG];
    int beginningIndex = 0;
    int endIndex = 0;

    for (int i = addIndex; fs->at(i) != ')'; i++)
    {
        endIndex = i;
        if (fs->substr(i, 2) == "='")
        {
            beginningIndex = i + 2; // last space encountered before name of function
        }
    }
    address = fs->substr(beginningIndex, endIndex - beginningIndex);
}

void RestEndpoint::populateEndpoints()
{
    if (mapToIndex[GET_TAG])
    {
        rest_endpoint get;
        get.httpMethod = "GET";
        get.method = getTagMethod(mapToIndex[GET_TAG]);
        get.description = getTagComment(mapToIndex[GET_TAG]);
        endpoints.push_back(get);
    }
    if (mapToIndex[POST_TAG])
    {
        rest_endpoint post;
        post.httpMethod = "POST";
        post.method = getTagMethod(mapToIndex[POST_TAG]);
        post.description = getTagComment(mapToIndex[POST_TAG]);
        endpoints.push_back(post);
    }
    if (mapToIndex[PUT_TAG])
    {
        rest_endpoint put;
        put.httpMethod = "PUT";
        put.method = getTagMethod(mapToIndex[PUT_TAG]);
        put.description = getTagComment(mapToIndex[PUT_TAG]);
        endpoints.push_back(put);
    }
    if (mapToIndex[PATCH_TAG])
    {
        rest_endpoint patch;
        patch.httpMethod = "PATCH";
        patch.method = getTagMethod(mapToIndex[PATCH_TAG]);
        patch.description = getTagComment(mapToIndex[PATCH_TAG]);
        endpoints.push_back(patch);
    }
    if (mapToIndex[DELETE_TAG])
    {
        rest_endpoint del;
        del.httpMethod = "DELETE";
        del.method = getTagMethod(mapToIndex[DELETE_TAG]);
        del.description = getTagComment(mapToIndex[DELETE_TAG]);
        endpoints.push_back(del);
    }
}

std::string RestEndpoint::getTagMethod(int tagIndex)
{
    int beginningIndex = 0;
    int endIndex = 0;

    for (int i = tagIndex; fs->at(i) != '('; i++)
    {
        endIndex = i + 1;
        if (fs->at(i) == ' ')
        {
            beginningIndex = ++i; // last space encountered before name of function
        }
    }
    return fs->substr(beginningIndex, endIndex - beginningIndex);
}

std::string RestEndpoint::getTagComment(int tagIndex)
{
    int beginningIndex = 0;
    int endIndex = tagIndex;
    for (int i = tagIndex; fs->substr(i - 3, 3) != "/**"; i--)
    {
        beginningIndex = i;
        if (fs->substr(i, 2) == "*/")
        {
            endIndex = i;
        }
        if (fs->at(i) == '}' || fs->at(i) == '{')
        { // There was no comment before previous function begins
            return "No Comment Found\n";
        }
    }

    std::string rawComment = fs->substr(beginningIndex, endIndex - beginningIndex);
    for (int i = 0; i < rawComment.length(); i++)
    {
        if (rawComment.substr(i, 2) == "* ")
        {
            rawComment.erase(i, 2);
        }
    }

    // Removes most occurrences of double spaces from comment
    for (int i = 0; i < rawComment.length(); i++)
    {
        if (rawComment.substr(i, 2) == "  ")
        {
            rawComment.erase(i, 2);
        }
    }
    return rawComment;
}

void RestEndpoint::setTagsIndex()
{
    for (int i = 0; i < fs->length(); i++)
    {
        if (fs->at(i) == '@')
        {
            if (fs->substr(i, ADDRESS_TAG.length()) == ADDRESS_TAG)
            {
                mapToIndex.insert(std::make_pair(ADDRESS_TAG, i));
                isEndpoint = true;
            }
            if (fs->substr(i, GET_TAG.length()) == GET_TAG)
            {
                mapToIndex.insert(std::make_pair(GET_TAG, i));
            }
            if (fs->substr(i, POST_TAG.length()) == POST_TAG)
            {
                mapToIndex.insert(std::make_pair(POST_TAG, i));
            }
            if (fs->substr(i, PUT_TAG.length()) == PUT_TAG)
            {
                mapToIndex.insert(std::make_pair(PUT_TAG, i));
            }
            if (fs->substr(i, PATCH_TAG.length()) == PATCH_TAG)
            {
                mapToIndex.insert(std::make_pair(PATCH_TAG, i));
            }
            if (fs->substr(i, DELETE_TAG.length()) == DELETE_TAG)
            {
                mapToIndex.insert(std::make_pair(DELETE_TAG, i));
            }
        }
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