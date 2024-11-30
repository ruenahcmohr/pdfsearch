#!/bin/bash
# Bash replacement of the PDFsearch.php script
# TONS AND TONS of ugly hacks here, pray it works
#    -- polprog
# Version 1.0: oct 2024
# version 2.0: Nov 2024 Mohr hacks added, Rue.
# version 3.0: Nov 2024 If term was on command line and there was only 1 result, just open it.

PDFVIEWER=acroread
term=""
store=/morfiles/doc/pdf/

getTerm() {
    term=$(dialog --backtitle "pdfsearch v2.0" --stdout --clear --title "PDF Search" --inputbox "Search term?" 0 50 $term)

    # Exit the script on empty query or user pressing cancel
    if [ $? -ne 0 ]; then clear; return 1; fi
    if [ ""$term = "" ]; then clear; return 1; fi 
    
}


doit() {

    #term=$(dialog --backtitle "pdfsearch v1.0" --stdout --clear --title "PDF Search" --inputbox "Search term?" 0 50 $term)

    # Exit the script on empty query or user pressing cancel
    #if [ $? -ne 0 ]; then clear; return 1; fi
    #if [ ""$term = "" ]; then clear; return 1; fi
    
    results=()
    IFS=$'\n' 
    while read -d $'\0' REPLY; do
	#echo "GOT $REPLY"
	results+=("$REPLY")
    done < <(find $store -iname "*${term}*.pdf" -print0 )
    #done < <(find $store -iname "*${term}*.pdf" -printf "%p\0" )

    connical=($(printf "%s\n" "${results[@]}" | grep -o '[^/]*$'))

    #echo FINAL ARRAY IS "${results[@]}"

    # Assemble dialog options
    listopts=
    i=0
    IFS=$'\n'
    for f in ${connical[@]}; do
	listopts="$listopts $i \"$f\""
	i=$((i+1))
    done

    # Display message if nothing found, start again
    if [ $i -eq 0 ]; then
	dialog --no-mouse --msgbox "No results! try https://www.digchip.com/datasheets/search.php?pn=${term}" 0 0;
	return 0;
    fi

    choice=0
  
    if [ $quick -ne 1 -o $i -ne 1 ]; then
    # Show the choice menu. this returns a single number that you chose
      choice=$(echo dialog --backtitle \"pdfsearch v2.0\" --stdout --menu \"Search results for \\\"$term\\\":\" 0 0 $i "$listopts" | sh)
    fi
    
    if [ $? -ne 0 ]; then clear; return 0; fi
    
    #echo "user chose $choice"
    # Start PDF viewer
    $PDFVIEWER ${results[$choice]} > /dev/null 2>&1 &

}

# run doit as long as it returns 0 
if [ $# -ne 0 ]; then
  term=$1
  quick=1
  doit || break;
  clear
else 
 quick=0
  while true; do 
    getTerm || break ;
    doit || break ;
  done
fi
