// Changelog:
// [2025-08-21] Added: Error handling for file output operations.
// [2025-07-31] Initial version of the Changelog and To-Do Generator utility.
//
// To-Do:
//
using System.Text.RegularExpressions;

namespace CLTDGen
{
    internal class Program
    {
        private const string ToDoPattern = @"(?:^|[\s/])(?:todo:|to\s?do:|to-do:)";
        private const string ChangelogPattern = @"(?:^|[\s/])(?:changelog:|change\s?log:|@changelog)";

        private const string changelogFilePath = "Changelog.md"; // Output file for changelog
        private const string todoFilePath = "To-Do.md"; // Output file for To-Do entries

        static void Main(string[] args)
        {
            // Default project directory
            string projectDirectory = Directory.GetCurrentDirectory();
            bool outToFile = false;
            string filePattern = "*.cs";

            // Parse command-line arguments
            foreach (string arg in args)
            {
                if (arg.ToLower().StartsWith("--help"))
                {
                    ShowHelp();
                    return;
                }
                if (arg.ToLower().StartsWith("--projectdir="))
                {
                    projectDirectory = arg.Substring("--projectDir=".Length);
                }
                if (arg.ToLower().StartsWith("--filepattern="))
                {
                    filePattern = arg.Substring("--filePattern=".Length);
                }
                if (arg.ToLower() == "--outtofile")
                {
                    outToFile = true;
                }
            }

            // Validate directory exists
            if (!Directory.Exists(projectDirectory))
            {
                Console.WriteLine($"Error: Directory '{projectDirectory}' not found.");
                return;
            }

            string[] csFiles = Directory.GetFiles(projectDirectory, filePattern, SearchOption.AllDirectories);

            List<string> changeLogLines = new List<string>();
            List<string> todoLines = new List<string>();

            Console.WriteLine($"Searching for Changelog and To Do in code File Headers:{Environment.NewLine}");

            foreach (string file in csFiles)
            {
                string[] lines = File.ReadAllLines(file);

                bool inHeader = true;
                bool changelogFound = false;
                bool todoFound = false;

                Console.WriteLine($"Processing File: {file}");

                foreach (string line in lines)
                {
                    if (inHeader)
                    {
                        // First we check if we found the first non-comment line that is not empty.
                        if (!line.TrimStart().StartsWith("//") && !string.IsNullOrWhiteSpace(line))
                        {
                            inHeader = false;
                            break;
                        }

                        string tLine = "";
                        if (line.TrimStart().StartsWith("//"))
                        {
                            tLine = line.Remove(0, 2).Trim();
                        }
                        else
                        {
                            tLine = line.TrimStart();
                        }

                        try
                        {
                            // Since this would be last in the header, we check for it first to avoid processing the first
                            // To Do line as a changelog entry.
                            if (!todoFound && Regex.IsMatch(line, ToDoPattern, RegexOptions.IgnoreCase))
                            {
                                todoFound = true;
                                changelogFound = false; // Reset changelogFound since we are now looking for To Do entries.
                                // Ok, done here so let's go to the next line.
                                continue;
                            }
                            else if (todoFound && line.TrimStart().StartsWith("//") && !string.IsNullOrEmpty(tLine))
                            {
                                todoLines.Add(tLine.Trim());
                                // Ok, done here so let's go to the next line.
                                continue;
                            }
                            else if (todoFound && !string.IsNullOrWhiteSpace(tLine))
                            {
                                // Why are we here? We found a To Do entry, but the line is not expected. Complain!
                                Console.WriteLine($"Unexpected To Do line in file {file}: {line}");
                            }
                        } catch (Exception ex)
                        {
                            Console.WriteLine($"To-Do: Error processing line in file {file}: {ex.Message}");
                        }

                        try
                        {
                            if (!changelogFound && Regex.IsMatch(line, ChangelogPattern, RegexOptions.IgnoreCase))
                            {
                                changelogFound = true;
                                todoFound = false; // Reset todoFound just in case.
                                // Ok, done here so let's go to the next line.
                                continue;
                            }
                            else if (changelogFound && line.TrimStart().StartsWith("//") && !string.IsNullOrEmpty(tLine))
                            {
                                changeLogLines.Add(tLine.Trim());
                                // Ok, done here so let's go to the next line.
                                continue;
                            }
                            else if (changelogFound && !string.IsNullOrWhiteSpace(tLine))
                            {
                                // Why are we here? We found a To Do entry, but the line is not expected. Complain!
                                Console.WriteLine($"Unexpected Changelog line in file {file}: {line}");
                            }
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Changelog: Error processing line in file {file}: {ex.Message}");
                        }
                    }
                }
            }

            // Create key-value pairs from changelog lines
            var changelogDict = CreateChangelogDict(changeLogLines);

            // Output the changelog results
            OutputChangelog(changelogDict, outToFile);
            // Write todoLines to file
            OutputToDo(todoLines, outToFile);
        }

        /// <summary>
        /// Converts changelog lines into a list of date-based entries.
        /// </summary>
        /// <param name="changeLogLines">The list of changelog entries. Each entry must start with a date in the format [YYYY-MM-DD].</param>
        /// <returns>A list where the first string is the date, and the second is a list of strings containing the title and description.</returns>
        private static List<KeyValuePair<string, List<string>>> CreateChangelogDict(List<string> changeLogLines)
        {
            var result = new List<KeyValuePair<string, List<string>>>();
            var lastDate = string.Empty;

            foreach (var line in changeLogLines)
            {
                string date = string.Empty;
                string remainingText = string.Empty;
                if (!string.IsNullOrEmpty(lastDate) && !line.StartsWith("["))
                {
                    date = lastDate; // Use the last date if the current line does not start with a date
                    remainingText = "    " + line.Trim();
                }
                else
                {
                    // Extract the date (substring [1,10])
                    date = line.Substring(1, 10);
                    lastDate = date; // Update the last date for subsequent lines
                    // Extract the remaining text after the date
                    remainingText = line.Substring(12).Trim();
                }

                // Check if the date is already a key in the list
                var existingEntry = result.FirstOrDefault(entry => entry.Key == date);
                if (existingEntry.Key != null)
                {
                    // If the date already exists, append the new details to the existing entry
                    existingEntry.Value.Add(remainingText);
                }
                else
                {
                    result.Add(new KeyValuePair<string, List<string>>(date, new List<string> { remainingText }));
                }
            }

            return result.OrderByDescending(entry => entry.Key).ToList();
        }

        /// <summary>
        /// Outputs the changelog to the console or writes it to a file based on the configuration.
        /// </summary>
        /// <remarks>If the output is configured to be written to a file, the changelog is saved to the
        /// specified file path. Otherwise, it is printed to the console. Ensure that the file path is valid and
        /// accessible if writing to a file.</remarks>
        /// <param name="changelogDict">A list of key-value pairs where each key is a date string and each value is a list of changelog details for
        /// that date.</param>
        private static void OutputChangelog(List<KeyValuePair<string, List<string>>> changelogDict, bool outToFile)
        {
            if (!outToFile)
            {
                Console.WriteLine($"{Environment.NewLine}Changelog:");
                foreach (var entry in changelogDict)
                {
                    Console.WriteLine($"Date: {entry.Key}");
                    foreach (var detail in entry.Value)
                    {
                        Console.WriteLine($"        {detail}");
                    }
                }
            }
            else
            {
                try
                {
                    using (StreamWriter changelogWriter = new StreamWriter(changelogFilePath))
                    {
                        changelogWriter.WriteLine($"# Changelog{Environment.NewLine}");
                        foreach (var entry in changelogDict)
                        {
                            changelogWriter.WriteLine($"{Environment.NewLine}## {entry.Key}");
                            foreach (var detail in entry.Value)
                            {
                                changelogWriter.WriteLine($"{detail}");
                            }
                        }
                    }
                    Console.WriteLine($"Changelog has been written to {changelogFilePath}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error writing changelog file: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// Outputs the list of to-do entries to the console or writes them to a file based on the configuration.
        /// </summary>
        /// <remarks>If the output is configured to be written to a file, the entries are saved to the
        /// file specified by the <c>todoFilePath</c> variable. Otherwise, the entries are printed to the
        /// console.</remarks>
        /// <param name="todoLines">A list of strings representing the to-do entries to be output.</param>
        private static void OutputToDo(List<string> todoLines, bool outToFile)
        {
            if (!outToFile)
            {
                Console.WriteLine($"{Environment.NewLine}To-Do Entries:");
                foreach (string line in todoLines)
                {
                    Console.WriteLine(line);
                }
            }
            else
            {
                try
                {
                    using (StreamWriter todoWriter = new StreamWriter(todoFilePath))
                    {
                        todoWriter.WriteLine($"# To-Do Notes{Environment.NewLine}");
                        foreach (string line in todoLines)
                        {
                            todoWriter.WriteLine(line);
                        }
                    }
                    Console.WriteLine($"To-Do entries have been written to {todoFilePath}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error writing to-do file: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// Displays a help message describing the purpose, usage, and options of the Changelog and To-Do Generator
        /// utility.
        /// </summary>
        /// <remarks>The help message includes an overview of the utility, the expected format for source
        /// code headers,  and detailed descriptions of the available command-line options. This method outputs the help
        /// information directly to the console.</remarks>
        private static void ShowHelp()
        {
            Console.WriteLine("Changelog and To-Do Generator for C# Projects");
            Console.WriteLine("=============================================");
            Console.WriteLine("Utility to generate Changelog and To-Do markdown files from C# source code file headers.");
            Console.WriteLine("");
            Console.WriteLine("Format for header files should look like this:");
            Console.WriteLine("// # Changelog:");
            Console.WriteLine("// [2025-09-25] Stuff done here.");
            Console.WriteLine("");
            Console.WriteLine("// To-Do");
            Console.WriteLine("// - We want to do this!");
            Console.WriteLine("");
            Console.WriteLine("Usage: CLTDGen [--projectDir=<path>] [--outToFile]");
            Console.WriteLine("Options:");
            Console.WriteLine("  --projectDir=<path>     Specify the project directory to search");
            Console.WriteLine("                          Default is current path you are calling the EXE from.");
            Console.WriteLine("  --filePattern=<pattern> Specify file pattern to search (default: \"*.cs\")");
            Console.WriteLine("                          Examples: \"*.cs\", \"*.{cs,js,ts}\"");
            Console.WriteLine("  --outToFile             Output results to file instead of console");
            Console.WriteLine("                          Default is false (output to screen)");
            Console.WriteLine("                          Files are written to same folder as the project");
            Console.WriteLine("  --help                  Show this help message");
        }
    }
}
