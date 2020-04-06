# ApexRestDocGen
A tool that recursively searches sub-directories for APEX Rest endpoints and generates a simple confluence-compatible table of found endpoints...

## To Build  
### UNIX  

Prequisites: CMake, G++ compiler

1. In project directory run `cmake ./`
2. In project directory run `make`

### WINDOWS

Prequisites: CMake, Visual Studio C++

1. In project directory run `mkdir build`
2. Run CMake GUI tool, select new `/project/build` as the build directory and `/project` as the project directory. Click configure. _may need to run configure twice to commit options_
3. Navigate to `/project/build` directory and run:

```
cmake --build ./ --config Release
```

4. Console should print where executable has been outputted


## To Use

### Executing program

The program can be executed from a terminal / shell by `./ApexRestDoc` or, on windows, `./ApexRestDoc.exe`.

### With options  

There are some flags available to customise how the program runs:
- **-p** [relative path] provide a relative path to a the base directory to perform the search for endpoints.
- **-o** [confluence, markdown] indicate whether to provide output as confluence markup or markdown table.
- **-i** [directory name to ignore] provide a string to ignore directories which have paths containing the string. e.g. given 'test' would ignore all folders named 'test' and their subfolders.

If no options are provided defaults to `./ApexRestDoc -p ./ -o confluence` 

Example usage:
`./ApexRestDoc -p ../src -o markdown -i _deprecated` would perform a search for endpoints at the 'src' folder one level above the executable and output in a format for confluence's markup format.

Example markdown output:
| **Name** | **Address** | **HTTP Method** | **Class Method** | **Description** |
| -------- | ----------- | --------------- | ---------------- | --------------- |
| ObjectiveRest | /tm/\*/objective/\* | Get | getObjectives |  Gets all of the subject team member's objectives.  |
| ObjectiveRest | /tm/\*/objective/\* | Delete | deleteObjective |  Delete an objective by ID  |
| ObjectiveCloseRest | /objective/\*/close | Post | closeObjective |  Closes an active objective.  |
| ObjectiveActivateRest | /objective/activate | Post | activateObjective |  Activate an objective  |
| ConversationBySubjectRest | /conversation/subject/\* | Get | getConversationBySubject | No doc comment found |
| ConversationRest | /conversation/\* | Get | getConversation |  Get a Conversation by ID.  |
| ConversationRest | /conversation/\* | Post | insertConversation |  Save a new Conversation.  |
| ProcessDetailsRest | /tm/\*/process-details | Get | getPerformanceOverviewDetails |  Gets the details of the Performance Overview process.  |
| TeamRest | /feedback/team | Get | getTeam |  Gets the list of possible subjects.  |

