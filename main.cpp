#include <iostream>
#include <string>
#include <list>

#include "./RestEndpoint.h"
#include "./FileUtils.h"

int main(int argc, char *argv[])
{
    std::list<RestEndpoint> endpoints;
    std::string mdString;
    clsProjectParser("./", endpoints);
    convertToMarkdown(endpoints, mdString);
    std::cout << mdString << std::endl;
    return 0;
}
