#!/usr/bin/env bash

COLUMNS="$(tput cols)"
WELCOME_MESSAGE="Welcome to Business Hall!"
TMPFILE=$(mktemp)

exec 3>"$TMPFILE"
exec 4<"$TMPFILE"

print_menu () {
    echo 
    echo "Select business file - - - - - - -(1)"
    echo "Print business data - - - - - - - (2)"
    echo "Update business data field - - - -(3)"
    echo "Print entire file - - - - - - - - (4)"
    echo "Save changes - - - - - - - - - - -(5)"
    echo "Exit - - - - - - - - - - - - - - -(6)"
    echo
    echo -n "Select one of the options above by typing the respective number: "
}

check_file () {
    if test ! -f "$FILE"; then
        echo "No file selected. Please select a file first."
        return 0
    else
        return 1
    fi
}

select_file () {
    echo -n "Enter the path to your selected business file: "
    read FILE_LOCATION
    if test -f "$FILE_LOCATION"; then
        echo
        echo "File selected!"
        FILE=$FILE_LOCATION
    else
        echo
        echo "File does not exist. Default file selected."
        FILE="./Businesses.csv"
    fi
    cp $FILE $TMPFILE
}

print_business_data () {
    echo -n "Enter business code: "
    read BUSINESS_CODE
    echo
    awk -F"," -v x="$BUSINESS_CODE" '$1==x {print}' $TMPFILE | column -s "," -t -N ID,BusinessName,Adress,City,PostCode,Longitude,Latitude
    echo
}

update_data () {
    echo -n "Enter business code: "
    read BUSINESS_CODE
    awk -F"," -v x="$BUSINESS_CODE" '$1==x {print}' $TMPFILE > tmp
    if [[ -s tmp ]]; then
        echo -n "Enter which field you would like to change: "
        read FIELD_INDEX

        echo "Old data:"
        echo
        awk -F"," -v x="$BUSINESS_CODE" '$1==x {print}' $TMPFILE | column -s "," -t -N ID,BusinessName,Adress,City,PostCode,Longitude,Latitude
        echo
        awk -v x="$BUSINESS_CODE" 'BEGIN {FS=OFS=","} $1==x {$2="Starbucks"} 1' $TMPFILE > tmp && mv tmp $TMPFILE
        echo "New data:"
        echo
        awk -F"," -v x="$BUSINESS_CODE" '$1==x {print}' $TMPFILE | column -s "," -t -N ID,BusinessName,Adress,City,PostCode,Longitude,Latitude
    else
        echo "Business code not found."
    fi
    rm -f tmp
    echo
}

print_entire_file () {
    echo
    cat $TMPFILE | column -s"," -t | more -df
}

save_changes () {
    echo -n "Are you sure to want to save the changes? (y,n) "
    read INPUT1
    if [[ "$INPUT1" =~ [yY] ]]; then
        cp $TMPFILE $FILE
        echo "Changes saved to $FILE."
    else
        echo "Changes not saved."
    fi
}

quit () {
    exec 3>&-
    rm "$TMPFILE"
    echo
    echo "Thank you for using Business Hall!" 
}

perform_action () {
    case "$1" in

        1)
            select_file
            ;;
        2)
            check_file
            RESULT=$?
            if test "$RESULT" -eq 1; then
                print_business_data
            fi
            ;;
        3)
            check_file
            RESULT=$?
            if test "$RESULT" -eq 1; then
                update_data
            fi
            ;;
        4)
            check_file
            RESULT=$?
            if test "$RESULT" -eq 1 ; then 
                print_entire_file
            fi
            ;;
        5)
            check_file
            RESULT=$?
            if test "$RESULT" -eq 1; then
                save_changes
            fi
            ;;
        6)
            quit
            ;;
        *)
            echo "Invalid input."
            ;;
    esac
}

# Main program starts here

# this block prints the welcome message
echo
echo
echo
printf "%*s\n" $(( (${#WELCOME_MESSAGE} + COLUMNS) / 2)) "$WELCOME_MESSAGE"
echo 
echo 

# main app prompt
INPUT=0
while [ "$INPUT" != "6" ]; do

    echo -n "Press <ENTER> to continue..."
    read

    print_menu
    read INPUT

    echo
    perform_action "$INPUT"

done
