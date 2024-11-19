#!/bin/bash
# Bash replacement of the PDFsearch.php script
# TONS AND TONS of ugly hacks here, pray it works
#    -- polprog
# Version 1.0: oct 2024

PDFVIEWER=evince
term=""
doit() {

    term=$(dialog --backtitle "pdfsearch v1.0" --stdout --clear --title "PDF Search" --inputbox "Search term?" 0 50 $term)

    # Exit the script on empty query or user pressing cancel
    if [ $? -ne 0 ]; then clear; return 1; fi
    if [ ""$term = "" ]; then clear; return 1; fi
    
    results=()
    IFS=$'\n' 
    while read -d $'\0'; do
	#echo "GOT $REPLY"
	results+=("$REPLY")
    done < <(find . -iname "*${term}*.pdf" -print0 )

    #echo FINAL ARRAY IS "${results[@]}"

    # Assemble dialog options
    listopts=
    i=0
    IFS=$'\n'
    for f in ${results[@]}; do
	listopts="$listopts $i \"$f\""
	i=$((i+1))
    done

    # Display message if nothing found, start again
    if [ $i -eq 0 ]; then
	dialog --msgbox "No results!" 0 0;
	return 0;
    fi

    # Show the choice menu. this returns a single number that you chose
    choice=$(echo dialog --backtitle \"pdfsearch v1.0\" --stdout --menu \"Search results for \\\"$term\\\":\" 0 0 $i "$listopts" | sh)
    if [ $? -ne 0 ]; then clear; return 0; fi
    
    #echo "user chose $choice"
    # Start PDF viewer
    $PDFVIEWER ${results[$choice]} &

}

# run doit as long as it returns 0 
while true; do doit || break ; done