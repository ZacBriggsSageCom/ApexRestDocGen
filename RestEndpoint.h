#ifndef RESTENDPOINT_H
#define RESTENDPOINT_H

#include <string>
#include <map>
#include <vector>
#include <iostream>

struct rest_endpoint
{
    std::string httpMethod;
    std::string method;
    std::string description;
};

class RestEndpoint
{
public:
    std::string *fs;
    std::string filename;

    std::string tags[6] = {
        "@RestResource",
        "@HttpGet",
        "@HttpPost",
        "@HttpPut",
        "@HttpPatch",
        "@HttpDelete"};

    std::map<std::string, int> mapToIndex;
    std::vector<rest_endpoint> endpoints;
    std::string address;
    bool isEndpoint;

    RestEndpoint(std::string &file, std::string &fileName);

    void print();

    ~RestEndpoint();

private:
    void setFile(std::string file);

    void populateAddress();

    void populateEndpoints();

    std::string getTagMethod(int tagIndex);

    std::string getTagComment(int tagIndex);

    void setTagsIndex();
};

#endif