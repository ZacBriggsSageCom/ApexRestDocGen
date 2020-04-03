#include "./FileUtils.h"

void clsProjectParser(std::string directoryPath, std::list<RestEndpoint> &endpointsOut)
{
    ClsFile *fileReader;
    RestEndpoint *rest;
    // Iterate through directories
    for (auto &p : fs::recursive_directory_iterator(directoryPath))
    {
        // Ignore if path contains '_deprecated' && Only create files for files ending in .cls
        if (p.path().string().find("_deprecated") == std::string::npos && p.path().extension().string() == ".cls")
        {
            fileReader = new ClsFile(p.path().string(), p.path().filename().string());
            // If file has an endpoint, save it to endpoint list
            if (fileReader->endpoint->isEndpoint)
            {
                endpointsOut.push_back(*fileReader->endpoint);
            }
        }
    }

    return;
}

void convertToMarkdown(std::list<RestEndpoint> endpoints, std::string &markdownOut)
{
    std::stringstream fmt;
    fmt << "| *Name* | *Address* | *HTTP Method* | *Class Method* | *Description* |" << std::endl;

    for (RestEndpoint r : endpoints)
    {
        replaceStringInString(r.address, "*", "\\*");
        for (rest_endpoint e : r.endpoints)
        {
            e.description.erase(std::remove(e.description.begin(), e.description.end(), '\n'), e.description.end());

            fmt << "| " << r.filename << " | " << r.address << " | " << e.httpMethod << " | " << e.method << " | " << e.description << std::endl;
        }
    }
    markdownOut = fmt.str();
}