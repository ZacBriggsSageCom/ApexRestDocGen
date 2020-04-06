#include <iostream>
#include <string>
#include <string.h>
#include <list>

#include "./RestEndpoint.h"
#include "./FileUtils.h"

void printHelpHeader()
{
    std::string header = "APEX Rest Endpoint Documenter\n"
                         "This command line utility can generate simple table-format documentation of Apex Rest endpoints. \n"
                         "usage: ApexRestDoc [options]";
    std::cout << header;
}
void printHelpOptions()
{
    std::string options =
        "options:\n"
        "\t-p [relative path] Provide a relative path to a director from which to begin a search for endpoints to document.\n"
        "\t-o [confluence, markdown] Choose whether to output to a table format compatible with confluence or generic markdown. \n";
    std::cout << options;
}

void printHelpNotes()
{
    std::string notes = "notes:\n"
                        "\tNo options given: The default execution of the program, given no options, is equivalent to 'ApexRestDoc -p ./ -o markdown'\n"
                        "\tDescriptions: Rely on doc-comment above functions tagged with each REST HTTP verb.\n";
    std::cout << notes;
}

void printHelp()
{
    printHelpHeader();
    printHelpOptions();
    printHelpNotes();
}

void commandLineParser(int argc, char **argv)
{
    std::string path = "./";
    bool outputMarkdown = false;
    bool outputConfluence = false;

    if (argc > 1 && strcmp(argv[1], "help") == 0)
    {
        printHelp();
        return;
    }
    // Scan for command line arguments
    for (int i = 1; i < argc - 1; i++)
    {

        std::string flag = argv[i];
        std::string arg = argv[i + 1];

        if (flag == "-p")
        {
            path = arg;
        }
        else if (flag == "-o")
        {
            if (arg == "confluence")
            {
                outputConfluence = true;
            }
            else if (arg == "markdown")
            {
                outputMarkdown = true;
            }
            else
            {
                std::cout << "Unknown output format '" << arg << "'"
                          << std::endl;
                printHelpOptions();
                return;
            }
        }
        else
        {
            std::cout << "Options not recognised" << std::endl;
            printHelp();
            return;
        }
    }
    // Where options have not been provided, set default ones
    if (outputMarkdown == false && outputConfluence == false)
    {
        outputMarkdown = true;
    }

    std::list<RestEndpoint> endpoints;
    try
    {
        clsProjectParser(path, endpoints);
    }
    catch (const std::invalid_argument &e)
    {
        std::cerr << e.what() << std::endl;
        return;
    }
    catch (const fs::filesystem_error &e)
    {
        std::cout << "Encountered an error, or permission denied, during recursion over filesystem." << std::endl;
        std::cerr << e.what() << std::endl;
        return;
    }

    if (outputConfluence)
    {
        std::string outputString;
        processToConfluenceMarkup(endpoints, outputString);
        std::cout << outputString << std::endl;
    }
    if (outputMarkdown)
    {
        std::string outputString;
        processToMarkdown(endpoints, outputString);
        std::cout << outputString << std::endl;
    }
}

int main(int argc, char *argv[])
{
    commandLineParser(argc, argv);
    return 0;
}
