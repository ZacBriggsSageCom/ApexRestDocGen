#include "./CommandLineParser.h"

void commandLineParser(int argc, char **argv)
{
    std::string path = "./";
    std::string ignoreString = "";
    bool ignoreStringSet = false;
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
        std::string flag = argv[i];    // to be checked if it is a flag
        std::string arg = argv[i + 1]; // if we have a flag, can assume this is its argument

        if (flag == "-p")
        {
            path = arg;
        }
        else if (flag == "-i")
        {
            ignoreString = arg;
            ignoreStringSet = true;
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
    }

    // Where options have not been provided, set default ones
    if (outputMarkdown == false && outputConfluence == false)
    {
        outputMarkdown = true;
    }

    std::list<RestEndpoint> endpoints;
    try
    {
        if (ignoreStringSet)
        {
            clsProjectParserWithIgnore(path, endpoints, ignoreString);
        }
        else
        {
            clsProjectParser(path, endpoints);
        }
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
        "\t-o [confluence, markdown] Choose whether to output to a table format compatible with confluence or generic markdown. \n"
        "\t-i [directory name to ignore] Will ignore directories containing provided string, e.g. '_deprecated' would ignore folders named '_deprecated' (and its subfolders).\n";
    std::cout << options;
}

void printHelpNotes()
{
    std::string notes = "notes:\n"
                        "\tWhere no options provided: The default execution of the program, given no options, is equivalent to 'ApexRestDoc -p ./ -o markdown'\n"
                        "\tDescriptions: Rely on doc-comment above functions tagged with each REST HTTP verb.\n";
    std::cout << notes;
}

void printHelp()
{
    printHelpHeader();
    printHelpOptions();
    printHelpNotes();
}