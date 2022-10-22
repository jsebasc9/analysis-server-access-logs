#!/bin/bash

# Array created as global to be used with list of file log names 
declare -a logFilesArray

# Function used to check if the input of user is a number and it is between the range of options
checkMenuUserEntry() { # Definition of checkMenuUserEntry function
    while true; do # Cycle to validate integer numbers and range of options
        read -p 'Please enter an option (#) : ' input # Reading user input for log file
        # Checking if the value is not an integer, string, or null and is not beetween the range of the numbers
        if ! [[ $input =~ ^[0-9]+$ ]] || [ $input -lt 0 ] || [ $input -gt $1 ]; then
            # Warning red message prompt for re entering integer and using >&2 to display the message in the console
            echo " $(tput setaf 1)Invalid value. Value must be a number between (0-$1). Please try again. $(tput setaf 7)" >&2 
        else # Because input meet requeriments
            return $input # Return value out of the function
        fi # Closing if steatment
    done # Ending while cycle
}

#Function used to check if the file exist
checkFileExist(){ # Definition of checkFileExist function
# BASIC FUNCTIONAL REQUERIMENTS POINT 2
    while true; do # Cycle to validate name of file
        read -p 'Please enter a log file name to create: ' input # Reading user input for text file
        if [[ -f "$input.csv" ]] || [[ -z $input ]]; then # Checking if input file exist or if user just press enter with no name
            # Print red error message where text file does not exist using >&2 to display the message in the console
            echo "$(tput setaf 1)This name has been already choosen or you did not enter a name. Please try again.$(tput setaf 7)" >&2
        else # In case text file exist
            echo "$input" # Returning text file name
            break # Breaking while cycle
        fi # End of if statement to check file name
    done # End of main while cycle
}

# Function used to check if the user input is equal to the operator less thand, more than, equal to, or different to.
checkOperator(){ # Definition of checkOperator function
    while true; do # Cycle to validate integer numbers
        read -p 'Please enter an input to search: ' input # Reading user input
        if [[ $input == "<" ]] || [ $input == ">" ] || [ $input == "==" ] || [ $input == "!=" ]; then # Checking if the value if one of the operators
            echo "$input" # returning input out of the function
            break # Breaking while cycle
        else # Because value is invalid
            # Warning red message prompt for re entering input using >&2 to display the message in the console
            echo " $(tput setaf 1)Invalid input. Please try again. $(tput setaf 7)" >&2 
        fi # Closing if steatment
    done # Ending while cycle
}

# Function used to check if the user input a valid in the criteria for SRC IP and DEST IP
checkCriteria(){ # Definition of checkCriteria function
    while true; do # Cycle to validate user input
        read -p "Please enter criteria what are you searching for : " input # Reading user input
        if [[ -z $input ]]; then # Checking if user just press enter and put no entry
            # Print red error message where input is invalid and using >&2 to display the message in the console
            echo "$(tput setaf 1)Invalid input. Please try again.$(tput setaf 7)" >&2 
        else # In case user enter an input
            echo "$input" # Returning input
            break # Breaking while cycle
        fi # End of if statement to check file name
    done # End of main while cycle
}

# Function used to check initial questions if the user want to check all avaiable log files or not, or exit the script
checkYesNoExit(){ # Definition of checkYesNoExit function
    while true; do # Cycle to validate Yes, No or Exit.
        read -p 'Would you like to search all available log files? (y/n), or input "exit" to end the script : ' selectionUser # Reading user input
        if [[ ${selectionUser^^} == "Y" ]] || [[ ${selectionUser^^} == "N" ]] || [[ ${selectionUser^^} == "EXIT" ]]; then # Checking if the value is yes, no, exit with case insensitive converting to uppercase
            echo "${selectionUser^^}" # Returning user input
            break # Breaking while cycle
        else # Because value is invalid
            # Warning red message prompt for re entering a valid input using >&2 to display the message in the console
            echo " $(tput setaf 1)Invalid input. Please try again. $(tput setaf 7)" >&2
        fi # Closing if steatment
    done # Ending while cycle
}

# Function used to check valid numerical input from user
checkNumericalInput(){ # Definition of checkNumericalInput function
    while true; do # Cycle to validate numerical inputs
        read -p 'Please enter an input to search : ' input # Reading user input
        if ! [[ $input =~ ^[0-9]+$ ]]; then # Checking if the value is not an integer
            # Warning red message prompt for re entering integer using >&2 to display the message in the console
            echo " $(tput setaf 1)Invalid value. Value must be a number. Please try again. $(tput setaf 7)"  >&2
        else # Because value is a valid integer
            echo "$input" # Return value out of the function
            break # Breaking while cycle
        fi # Closing if steatment
    done # Ending while cycle
}

# This is part of Basic Functional Requeriments Point 1, 2
# Function used to check if server log csv files exist and put them into an array
getFileNames() { # Definition of getFileNames function
    sample="serv_acc_log.+csv$" # Setting pattern to look in directory
    local fileExistent=0 # Local flag to be used in checking of existing files
    for fileName in ./*; do # Using for statement to look for files on directory
        if [[ "$fileName" =~ $sample ]]; then # If there are files that match the pattern
            fileExistent=1 # Setting variable to confirm there is a .csv file
            break # Break for cycle as soon as there are .csv log access files existent
        fi # Closing if steatment
    done # Ending for cycle

    if [ $fileExistent -eq 1 ]; then # If Flag fileExistent is equal to 1 there are server log files
        for fileName in ./*; do # Using for statement to look for files on directory
            if [[ "$fileName" =~ $sample ]]; then # If there are files that match the pattern
                displayName="$( echo "$fileName" | sed -e 's#^./##' ) " # Set variable to removing (./) string directory
                logFilesArray+=($displayName) # Adding filename to log files array
            fi # Closing if steatment
        done # Ending while cycle
    else # In case there are not log access .csv files display next message
        # Warning red message where there are no server access log files
        echo "$(tput setaf 1)There are not .csv files server logs to access, please check directory . . .$(tput setaf 7)"
        exit 0 # Ending the script
    fi # Closing if steatment
}

# This is part of Basic Functional Requeriments Point 1, 2
# Function used to search criteria input in PROTOCOL, SRC PORT, DEST PORT and ClASS
searchCriteria() { # Definition of searchCriteria function
# BASIC FUNCTIONAL REQUERIMENTS POINT 1
    # Using grep and sed to clean and organize the data in a new file
    grep -v 'normal' temporal.csv | # Avoiding normal records in CLASS field, and then passing on grep
    sed 's/[[:blank:]]//g' | #  replacing whitespace and then passing on awk
    # Formatting columns and exporting content from temporal file to end user .csv file
    # where search criteria input is equal to values in the respective column with field 
    # separtor as "," or "\r" for last column and convertirng values to uppercase to be case insensitive
    awk 'BEGIN {FS=",|\r"}
        NR>1 {
        if(toupper($'"$2"')==toupper("'"$4"'")){
            printf "%-10s %-15s %-10s %-15s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6, $7, $8;
        }
    }' >> "$3".csv # BASIC FUNCTIONAL REQUERIMENTS POINT 2
    rm temporal.csv # Removing temporal file
}

# This is part of Basic Functional Requeriments Point 4, 2 and Advanced Functional Requeriments Point 3
# Function used to find BYTES and PACKETS with operators <,>,=,!=
searchBytesandPackets(){ # Definition of searchBytesandPackets function
# BASIC FUNCTIONAL REQUERIMENTS POINT 4
    # Using grep and sed to clean and organize the data in a new file
    grep -v 'normal' temporal.csv | # Avoiding normal records in CLASS field, and then passing on grep
    # Formatting columns and exporting content from temporal file to end user .csv file
    # where criteria input is <,>,=, or =! of the values in the respective column with field separtor as ","
    awk 'BEGIN {FS=","}
    NR>1 {
            if($'"$1"' '"$4"' '"$5"'){
            printf "%-10s %-15s %-10s %-15s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6, $7, $8;
            }
    }' >> "$3".csv
    rm temporal.csv # Removing temporal file
    # ADVANCED FUNCTIONAL REQUERIMENTS POINT 3
    # Getting total of PACKETS OR BYTES in end user .csv file and adding total to totalTemporal.csv file
    # where criteria input is <,>,=, or =! of the values in the respective column with field separtor as " "
    awk 'BEGIN {FS=" "}
    NR>1 {
            if($'"$1"' '"$4"' '"$5"'){
            total+=$'"$1"'
            }
    }END{print total}' < "$3".csv > totalTemporal.csv
}

# This is part of Basic Functional Requeriments Point 5, 2
# Function used to look for matches in SRC IP and DEST IP  using partial search
findMatchesSRCandDES(){ # Definition of findMatchesSRCandDES function
# BASIC FUNCTIONAL REQUERIMENTS POINT 5
    grep -v 'normal' temporal.csv | # Avoiding normal records in CLASS field, and then passing on grep
    # Formatting columns and exporting content from temporal file to end user .csv file
    # where criteria input match values in the respective column with field separtor as ","
    # and convertirng values to uppercase to be case insensitive
    awk 'BEGIN {FS=","}
    NR>1 {
            if(toupper($'"$4"') ~ toupper("'"$2"'")){
                printf "%-10s %-15s %-10s %-15s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6, $7, $8;
            }
    }' >> "$3".csv
    rm temporal.csv # Removing temporal file     
}

# This is part of Basic Functional Requeriments Point 1, 2, 3, 4
# Function used to select field and execute one or all available files depending on user input
selectFields() { # Definition of selectFields function
    # Array created to be used whit list of fields in the criteria search
    declare -a arrayFields=("PROTOCOL" "SRC IP" "SRC PORT" "DEST IP" "DEST PORT" "PACKETS" "BYTES" "CLASS") 
    if [[ $1 == "Y" ]]; then # In case user select all files
        # Display file log selected substrating 1 for the position
        echo "$(tput setaf 4)You have selected all available log files, what field would you like to search?$(tput setaf 7)"  
        local logFileSelected=${logFilesArray[0]} # Setting variable to start the process in the first available file
    elif [[ $1 == "N" ]]; then # In case user user wants o select only one file
        maxFirstMenuRange=${#logFilesArray[@]}
        checkMenuUserEntry $maxFirstMenuRange  # Calling function to validate user entry for first menu with maximun range as argument 
        local entryFirstMenuSelected=$? # Setting the valid user entry for the first menu
        local logFileSelected=${logFilesArray[$entryFirstMenuSelected-1]} # Setting variable with name of file to be used in the search less one because array starts in position 0
        echo "$(tput setaf 4) You have selected ($entryFirstMenuSelected) $logFileSelected, what field would you like to search? $(tput setaf 7)"  # Display file log selected
    fi
    for x in "${!arrayFields[@]}"; do # Looping through array indices or keys to compare and unset no prime number index
        echo "$(tput setaf 2) ($(($x+1))) - ${arrayFields[x]} $(tput setaf 7)" # Display log file name assigned to number adding 1 for the display position in green color
    done # End of for cycle
    maxSecondMenuRange=${#arrayFields[@]}
    checkMenuUserEntry $maxSecondMenuRange # Calling function to validate user entry for second menu with maximun range in the menu as argument 
    local entrySecondMenuSelected=$? # Setting the valid user entry for the second menu
        
    fieldName=${arrayFields[$entrySecondMenuSelected-1]} # Setting variable with name of field to be used in the search less one because array starts in position 0
    echo "$(tput setaf 4) You have selected ($entrySecondMenuSelected) - $fieldName $(tput setaf 7)" # Display field selected in blue
    # BASIC FUNCTIONAL REQUERIMENTS POINT 2
    userlogFileName=$(checkFileExist) # Setting variable with function to read user input for log .csv file
    cut -d "," -f 3,4,5,6,7,8,9,13 $logFileSelected > temporal.csv # Taking only important fields in a new temporal file
    head -n 1 temporal.csv | # Taking header from temporal file, pipe and then
    # Adding header with format in final file selected by the user
    awk 'BEGIN {FS=","}
        {printf "%-10s %-15s %-10s %-15s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $6, $7, $8}' > "$userlogFileName".csv

    if [ $entrySecondMenuSelected -eq 6 ] || [ $entrySecondMenuSelected -eq 7 ]; then # In case user entry is 6 or 7 Bytes and Packets match function will be called
        local entrySearchUser=$(checkNumericalInput) # Setting entryUser for search criteria
        # BASIC FUNCTIONAL REQUERIMENTS POINT 4
        # Display third menu option for operators in yellow
        echo "$(tput setaf 4)Which operator would you choose to find the match in $fieldName :"
        echo -e "$(tput setaf 3) (>) - $fieldName greater than $entrySearchUser\n (<) - $fieldName less than $entrySearchUser\n (==) - $fieldName equal to $entrySearchUser\n (!=) - $fieldName not equal to $entrySearchUser\n$(tput setaf 7)"
        entryOperator=$(checkOperator) # Setting entry option operator checking valid user input with CheckOperator function
    
        # ADVANCED FUNCTIONAL REQUERIMENTS POINT 2
        if [[ $1 == "Y" ]]; then # In case user select all available files
            for x in "${!logFilesArray[@]}"; do # Looping through array indices or keys to compare and unset no prime number index
                cut -d "," -f 3,4,5,6,7,8,9,13 ${logFilesArray[x]} > temporal.csv # Taking only important fields in a new temporal file
                # Calling searchBytesandPackets with second menu option selected, log server file slected
                # user csv file to create, field name selected, input criteria to search, and operator to compare.
                searchBytesandPackets $entrySecondMenuSelected ${logFilesArray[x]} $userlogFileName $entryOperator $entrySearchUser
            done # End of for cycle
        else
            # BASIC FUNCTIONAL REQUERIMENTS POINT 4 and ADVANCED FUNCTIONAL REQUERIMENTS POINT 3
            # Calling searchBytesandPackets with second menu option selected, log server file slected
            # user csv file to create, field name selected, input criteria to search, and operator to compare.
            searchBytesandPackets $entrySecondMenuSelected $logFileSelected $userlogFileName $entryOperator $entrySearchUser 
        fi
        # ADVANCED FUNCTIONAL REQUERIMENTS POINT 3
        # Getting total of Packets or Bytes from temporal file created prevoiusly with total in searchBytesandPackets function
        totalPacketsorBytes=$(head -n 1 totalTemporal.csv) 
        rm totalTemporal.csv # Removing temporal file
        echo "Total $fieldName is $totalPacketsorBytes" >> "$userlogFileName".csv # Adding total of Packets or Bytes to final user csv file.
    # BASIC FUNCTIONAL REQUERIMENTS POINT 5
    elif [ $entrySecondMenuSelected -eq 2 ] || [ $entrySecondMenuSelected -eq 4 ]; then # In case user entry is 2 or 4 fields (SRC IP or DEST IP)
        entryCriteria=$(checkCriteria) # Setting variable with valid input for search criteria 
        # ADVANCED FUNCTIONAL REQUERIMENTS POINT 2
        if [[ $1 == "Y" ]]; then # In case user select all available files
            for x in "${!logFilesArray[@]}"; do # Looping through array indices
                cut -d "," -f 3,4,5,6,7,8,9,13 ${logFilesArray[x]} > temporal.csv # Taking only important fields in a new temporal file
                # BASIC FUNCTIONAL REQUERIMENTS POINT 5
                # Calling findMatchesSRCandDES with log server file selected, search criteria input,
                # user csv file to create, and second menu option selected.
                findMatchesSRCandDES ${logFilesArray[x]} $entryCriteria $userlogFileName $entrySecondMenuSelected
            done # End of for cycle
        else
            # BASIC FUNCTIONAL REQUERIMENTS POINT 5
            # Calling findMatchesSRCandDES with log server file selected, search criteria input,
            # user csv file to create, and second menu option selected.
            findMatchesSRCandDES $logFileSelected $entryCriteria $userlogFileName $entrySecondMenuSelected
        fi
    else
        entryCriteria=$(checkCriteria) # Setting variable with valid input for search criteria 
        # ADVANCED FUNCTIONAL REQUERIMENTS POINT 2
        if [[ $1 == "Y" ]]; then # In case user select all available files
            for x in "${!logFilesArray[@]}"; do # Looping through array indices
                cut -d "," -f 3,4,5,6,7,8,9,13 ${logFilesArray[x]} > temporal.csv # Taking only important fields in a new temporal file
                # BASIC FUNCTIONAL REQUERIMENTS POINT 1
                # Calling searchCriteria with log server file selected, second menu option selected,
                # user csv file to create, and search criteria input.
                searchCriteria ${logFilesArray[x]} $entrySecondMenuSelected $userlogFileName $entryCriteria
            done # End of for cycle
        else
            # BASIC FUNCTIONAL REQUERIMENTS POINT 1
            # Calling searchCriteria with log server file selected, second menu option selected,
            # user csv file to create, and search criteria input.
            searchCriteria $logFileSelected $entrySecondMenuSelected $userlogFileName $entryCriteria # .......................................
        fi
    fi
    # BASIC FUNCTIONAL REQUERIMENTS POINT 2
    cat "$userlogFileName".csv # Displaying information on terminal
}

while true; do # Main Cycle to validate if user finish script
        getFileNames # Calling getFileNames function
        echo -e "\nWelcome to the script to identify and report upon suspicious activity." # Display message to access a menu options in blue and green
        echo "$(tput setaf 4) List of server access logs : $(tput setaf 7)"
        for x in "${!logFilesArray[@]}"; do # Looping through array indices
            echo "$(tput setaf 2) ($(($x+1))) - ${logFilesArray[x]} $(tput setaf 7)" # Display log file name assigned to position + 1 in the array in green color
        done # End of for cycle
        selectionUser=$(checkYesNoExit) # Calling function to validate if user chose Yes No or Exit
        if [[ ${selectionUser^^} == "EXIT" ]]; then # In case user chose Exit script will end
            echo "$(tput setaf 1)Ending script . . ." # Display message before ending script
            exit 0 # Ending Shell Script
        fi
        selectFields $selectionUser # Calling selectFields function to search or match inputs criteria
        logFilesArray=() # Clearing log files array
done # End of main while cycle