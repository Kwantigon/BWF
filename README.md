# BWF
Repository for the bwf.sh script
A Linux script used for obtaining useful information from the BWF website (https://bwfbadminton.com/)

Examples of usage:

RANKING

./bwf.sh r                        displays the top 69 players in the men's singles category on the leaderboards

./bwf.sh ranking                  this will do the same as the example above

./bwf.sh -c wd r                  displays the top 69 duos in the women's doubles category on the leaderboards

./bwf.sh -c ws -n 123 r           displays the top 123 players in the women's singles category on the leaderboards

./bwf.sh -s 'My Name' r           searches for a player named 'My Name' in the top 69 positions

./bwf.sh -s 'My Name' -n 300 r    searches for a player named 'My Name' in the top 300 positions

./bwf.sh -s '291' r               searches for the player with rank number 291

./bwf.sh -s '222' -c xd r         searches for the duo with rank number 222 in mixed doubles category

./bwf.sh -d 'last Wednesday' r    shows the top 69 players in the men's singles category for last Wednesday

./bwf.sh -d '20180415' -c md r    shows the top 69 duos in men's doubles for the week of 2018 April 15

TOURNAMENTS

./bwf.sh t                        shows all upcoming tournaments up until the end of the current year
       
./bwf.sh -d '20180516' t          shows all tournaments from the week of 2018 May 16 until the end of 2018

./bwf.sh -f -d '20190201' t       shows all completed tournaments from the week of 2019 February up until the current week





bwf.sh -h


Usage: bwf.sh...[options]...[COMMAND]

bwf.sh retrieves this week's BWF ranking or upcoming tournaments

COMMANDS:

'r' or 'ranking'        show this week's top 69 players

Options:

        -c CATEGORY             show ranking for given category
        CATEGORY format:        "ms" or "men's singles"
                                "ws" or "women's singles"
                                "md" or "men's doubles"
                                "wd" or "women's doubles"
                                "xd" or "mixed doubles"

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

        -h                      display this help and exit
