# ApexRestDocGen
A tool that recursively searches sub-directories for APEX Rest endpoints and generates a simple confluence-compatible table of found endpoints...

# To Build
## UNIX 
Prequisites: CMake, G++ compiler 

1. In project directory run `cmake ./`
2. In project directory run `make`

## WINDOWS
Prequisites: CMake, Visual Studio C++

1. In project directory run `mkdir build`
2. Run CMake GUI tool, select new `/project/build` as the build directory and `/project` as the project directory. Click configure. *may need to run configure twice to commit options*
3. Navigate to `/project/build` directory and run:
```
cmake --build ./ --config Release
```
4. Console should print where executable has been outputted
