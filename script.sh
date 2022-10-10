#! /bin/bash

menu()
{
    until [[ "$MENU" == "Exit" || "$MENU" == "" ]]; do
        MENU=`zenity --list --column Menu "${MENU_LIST[@]}" --height 250 --width 400`
        case "$MENU" in
            "Choose specific country population statistics") choose_country;;
            *);;
        esac
    done
}

get_country_info()
{
    COUNTRY_POPULATION=`grep cp1\" $COUNTRY_INFO_FILE | cut -d '>' -f 4`
    COUNTRY_POPULATION=${COUNTRY_POPULATION%</div}

    COUNTRY_BIRTHS=`grep cp7\" $COUNTRY_INFO_FILE | cut -d '>' -f 4`
    COUNTRY_BIRTHS=${COUNTRY_BIRTHS%</div}

    COUNTRY_DEATHS=`grep cp9\" $COUNTRY_INFO_FILE | cut -d '>' -f 4`
    COUNTRY_DEATHS=${COUNTRY_DEATHS%</div}

    COUNTRY_GROWTH=`grep cp12\" $COUNTRY_INFO_FILE | cut -d '>' -f 4`
    COUNTRY_GROWTH=${COUNTRY_GROWTH%</div}
}

choose_country()
{
    if [[ ! -f "$COUNTRY_LIST_FILE" ]]; then
        zenity --warning --width 20 --text "Error! Try again!"
        return;
    fi

    while [[ "$FOUND_COUNTRY" == "FALSE" ]]; do
        COUNTRY=`zenity --entry --title "" --text "Type name of the country"`
        if [[ $? -eq 1 ]]; then return; fi
        change_coutry_to_fit_pattern
        check_country_on_the_list
    done

    update_country_info
    get_country_info
    print_country_info
    FOUND_COUNTRY="FALSE"
}

change_coutry_to_fit_pattern() 
{
    TEMP_ARRAY=()
    COUNTRY=`echo $COUNTRY | tr -s ' '`
    for i in $COUNTRY; do
        TEMP=`echo $i | tr '[:upper:]' '[:lower:]'`
        if [[ $TEMP != "and" ]]; then 
            TEMP=`echo ${TEMP^}` 
        fi
        TEMP_ARRAY+=($TEMP)

    done
    COUNTRY=`echo ${TEMP_ARRAY[@]}`
    COUNTRY=`echo $COUNTRY | tr ' ' '_'`
}

check_country_on_the_list()
{
    grep -q $COUNTRY "$COUNTRY_LIST_FILE"
    [[ $? -eq 0 ]] && FOUND_COUNTRY="TRUE" || FOUND_COUNTRY="FALSE"
}

update_country_info()
{
    wget -O "$COUNTRY_INFO_FILE" "$MAIN_URL"/"$COUNTRY"
}

print_country_info()
{
    COUNTRY=`echo $COUNTRY | tr '_' ' '`
    zenity --info --title "Statistics for: $COUNTRY" --height 150 --width 300\
        --text "\nCurrent population: $COUNTRY_POPULATION\
            \nBirths today: $COUNTRY_BIRTHS\nDeaths today: $COUNTRY_DEATHS\
            \nPopulation growth year to date: $COUNTRY_GROWTH"
}

get_country_list()
{
    wget -O "$COUNTRY_LIST_FILE" "$MAIN_URL"
}

delete_files()
{
    rm /tmp/country_info.$$
    rm /tmp/country_list.$$
}

MAIN_URL="https://countrymeters.info/en"

COUNTRY_INFO_FILE="/tmp/country_info.$$"
COUNTRY_LIST_FILE="/tmp/country_list.$$"

FOUND_COUNTRY="FALSE"
COUNTRY="NONE"
COUNTRY_POPULATION=0
COUNTRY_BIRTHS=0
COUNTRY_DEATHS=0
COUNTRY_GROWTH=0

MENU_LIST=("Choose specific country population statistics" "Exit")
MENU=","

get_country_list
menu
delete_files

exit 0 
