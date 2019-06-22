#!/bin/bash
cleanup() {
        rm -f bwfSource players countries names ranking searchThis wn td tn tourneys
}
trap cleanup 0

## country search is different for doubles and singles ##

usage() {
        echo "Usage: $0...[options]...[COMMAND]"
        echo "$0 retrieves this week's BWF ranking or upcoming tournaments"
        echo "COMMANDS:
'r' or 'ranking'        show this week's top 69 players
Options:
        -c CATEGORY             show ranking for given category
        CATEGORY format:        \"ms\" or \"men's singles\"
                                \"ws\" or \"women's singles\"
                                \"md\" or \"men's doubles\"
                                \"wd\" or \"women's doubles\"
                                \"xd\" or \"mixed doubles\"

        -d 'DATE STRING'        show ranking of the week given by DATE STRING
                                DATE STRING format is the same as the one used in
                                'date' command

        -n NUMBER               show the top NUMBER players

        -s 'SEARCH STRING'      search the leaderboard using 'SEARCH STRING'
                                can search by player name, rank or country

't' or 'tournaments'    show this year's upcoming tournaments
Options:
        -f                      show only completed tournaments

        -a                      show both completed and upcoming tournaments

        -d 'DATE STRING'        show all tournaments from DATE STRING
                                until the end of that year

        -s 'SEARCH STRING'      show tournaments which have SEARCH STRING
                                in their name (ignores case)
                                SEARCH STRING can be in DATE STRING format.
                                In this case it will search for tournaments
                                which took place (or will take place)
                                during the week given in SEARCH STRING
Other non-COMMAND related options:
        -v                      display debug output

        -h                      display this help and exit"
}

GetYnW() {
        # Get year and week number from the given string #
        year=$( date -d "$1" +%Y 2>/dev/null)
        # Check if the date string format is valid #
        if [ $? -eq 1 ] && [ $search -eq 0 ]; then # do not exit if this function was called from toursearch #
                echo "Invalid date: \"${1}\"" >&2
                echo "See manual page of 'date' command for date string info" >&2
                exit 42
        else
                if [ $year -lt $( date +%Y ) ]; then
                        type=all
                fi
        fi
        weekNumber=$( date -d "$1" +%V 2>/dev/null )
}

singles() {
        # Get bwf site's page source #
        http "https://bwfbadminton.com/rankings/2/bwf-world-rankings/${categNumber}/${category}/${year}/${weekNumber}/?rows=${rows}&page_no=1" > bwfSource

        # Grep players' countries #
        grep -A 6 '<!-- Country and flag -->' bwfSource | grep -Eo 'title="[^"]*"' |
                grep -Eo '".*"' | tr -d "\"" > countries

        # Grep players' names #
        grep -A 5 '<!-- Player name -->' bwfSource | grep '</a>' | rev |
                tr -s "[:blank:]" | cut -f 2- -d ' ' | rev | sed 's/^ //' > names

        # Paste files together #
        paste countries names > ranking

        # Print formatted output #
        awk -F '\t' '{ printf "%d\t%-17s\t%s\n", NR, $1, $2 }' ranking
}

doubles() {
        # Get bwf site's page source #
        http "https://bwfbadminton.com/rankings/2/bwf-world-rankings/${categNumber}/${category}/${year}/${weekNumber}/?rows=${rows}&page_no=1" > bwfSource

        # Filter out players' info #
        grep -C 8 'Player name' bwfSource > players

        # Grep player names #
        grep '</a>' players | grep -Eo '>.*<' | tr -d '><' > names

        # Grep players' countries #
        grep -E '<.* title="[^"]*">' players | grep -Eo '"[^"]*">' |
                grep -Eo '[a-zA-Z ]*' | sed 's/$/\n/' > countries

        # Make output file #
        paste countries names > ranking

        # Print output #
        awk -v "rank=1" '{ if (NR%2 == 1) { printf "%d\t%s\n", rank, $0; rank++ } else {print "\t", $0} }' ranking
}
ranking() {
        # Fix variables to use in http link #
        case "$category" in
                ms | "men's singles")   category='men-s-singles'
                                        categNumber=6
                                        singles
                                        ;;
                ws | "women's singles") category='women-s-singles'
                                        categNumber=7
                                        singles
                                        ;;
                md | "men's doubles")   category='men-s-doubles'
                                        categNumber=8
                                        doubles
                                        ;;
                wd | "women's doubles") category='women-s-doubles'
                                        categNumber=9
                                        doubles
                                        ;;
                xd | "mixed's doubles") category='mixed-doubles'
                                        categNumber=10
                                        doubles
                                        ;;
        esac
}

ranksearch() {
        ranking > searchThis
        if [ "$categNumber" -ge 8 ]; then
                grep -A 1 -i "$searchString" searchThis | sed '/^--$/d'
        else
                grep -i "$searchString" searchThis
        fi
        if [ $? -eq 1 ]; then
                echo "Found nothing for \"${searchString}\" in the first ${rows} entries" >&2
        fi
}

tournaments() {
        http "https://bwfbadminton.com/calendar/${year}/${type}/" > bwfSource
        # Filter out necessary info into files #
        grep -A 2 '<!-- Week number -->' bwfSource | grep '</td>' |
                grep -Eo '[0-9][0-9]' > wn

        # Filter out tournament dates #
        grep -A 2 '<!-- Tournament date -->' bwfSource | grep '</td>' |
                grep -Eo '[0-9]+-[0-9]+' > td

        # Filter out tournament names #
        grep -A 3 '<!-- Tournament name -->' bwfSource | grep '</a>' |
                grep -Eo '>[^<]*</a' | tr -d '><' | cut -f 1 -d '/' |
                tr -s '[:blank:]' > tn

        # Write to output #
        echo "Week      Date    Name of tournament"
        echo "------------------------------------"
        paste wn td tn > tourneys
        awk -v "week=${weekNumber}" '{ if ($1>=week) {print $0} }' tourneys
}

toursearch() {
        tournaments > searchThis
        GetYnW "$searchString"
        if [ $? -eq 1 ]; then
                grep -i "$searchString" searchThis
        else
                grep "$weekNumber" searchThis
        fi
}

# Set default values #
if [ $# -eq 0 ]; then
        echo "NO COMMAND WAS GIVEN" >&2
        usage
        exit 42
fi
rows=69
category=ms
categNumber=6
search=0
GetYnW
type=remaining
# Set default values #

while getopts ':vhc:d:n:s:af' option; do
        case "$option" in
                c)      category="$OPTARG"
                        ;;
                d)      dateString="$OPTARG"
                        GetYnW "$dateString"
                        ;;
                n)      rows="$OPTARG"
                        ;;
                s)      searchString="$OPTARG"
                        search=1
                        # Check if user wants to search for a specific rank #
                        echo "$searchString" | grep -Eoq '[0-9]+'
                        if [ $? -eq 0 ]; then
                                rows=$searchString
                        # note that $rows is not used in function tournaments so it doesn't matter, if it's accidentally changed to date string by this #
                        fi
                        ;;
                a)      type=all
                        ;;
                f)      type=completed
                        ;;
                h)      usage
                        exit 0
                        ;;
                v)      set -x
                        ;;
        esac
done

while [ $# -gt 1 ]; do
        shift
done
case "$1" in
        r | ranking)            if [ "$search" -eq 1 ]; then
                                        command=ranksearch
                                else
                                        command=ranking
                                fi
                                ;;
        t | tournaments)        if [ "$search" -eq 1 ]; then
                                        GetYnW $searchString
                                        if [ -z "$year" ]; then
                                                getYnW $dateString
                                        fi
                                        command=toursearch
                                else
                                        command=tournaments
                                fi
                                ;;
esac
$command
