# Changelog and To-Do Generator (CLTDGen)

## Overview
CLTDGen is a utility designed to generate `Changelog.md` and `To-Do.md` files from C# source code file headers. It scans the project directory for specific patterns in comments and outputs the results either to the console or to markdown files.

## Features
- Extracts changelog entries from source code headers.
- Extracts to-do items from source code headers.
- Outputs results to the console or markdown files.
- Configurable via command-line arguments.

## Requirements
- .NET 8.0 SDK or later
- C# 12.0 support

## Usage
Run the application from the command line with the following options:
CLTDGen [--projectDir=<path>] [--filePattern=<pattern>] [--outToFile] [--help]

### Options
- `--projectDir=<path>`  
  Specify the project directory to search. Default is the current directory.

- `--filePattern=<pattern>`  
  Specify the file pattern to search. Default is `*.cs`.  
  Examples: `*.cs`, `*.{cs,js,ts}`

- `--outToFile`  
  Output results to markdown files (`Changelog.md` and `To-Do.md`) instead of the console. Files are written to the same folder as the project.

- `--help`  
  Display help information.

### Example
CLTDGen --projectDir=C:\MyProject --filePattern=*.cs --outToFile

## File Format
### Changelog
Changelog entries must start with a date in the format `[YYYY-MM-DD]`. Example:
// Changelog:
// [2025-08-21] Added: Error handling for file output operations.

### To-Do
To-Do entries must be prefixed with `To-Do:` or similar patterns. Example:
// To-Do:
// - Implement error handling for file access issues.


## Publishing the Application for Release
To publish the application for release, follow these steps:

1. **Ensure .NET SDK is Installed**  
   Make sure you have the .NET 8.0 SDK installed on your system. You can download it from [Microsoft's .NET website](https://dotnet.microsoft.com/).

2. **Open the Solution in Visual Studio**  
   Open the `CLTDGen` project in Visual Studio 2022 or later.

3. **Set the Build Configuration**  
   - In Visual Studio, set the build configuration to `Release` using the dropdown in the toolbar.

4. **Publish the Application**  
   - Right-click on the project in the Solution Explorer and select __Publish__.  
   - Choose a target folder or other deployment options as needed.  
   - Follow the wizard to complete the publishing process.

5. **Run the Published Application**  
   Navigate to the output folder and run the published executable.

Alternatively, you can publish the application using the .NET CLI:
dotnet publish -c Release -o <output-folder>

Replace `<output-folder>` with the desired output directory.
