#! /bin/bash

function menu()
{
    until [[ "$MENU" == "Exit" || "$MENU" == "" ]]; do
        MENU=`zenity --list --column Menu "${MENU_LIST[@]}" --height 250 --width 400`
        case "$MENU" in
            "Choose specific country population statistics") choose_country;;
            *);;
        esac
    done
}

function get_country_population()
{
    
}

function get_country_births()
{

}

function get_country_deaths()
{

}

function choose_country()
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

    update_country_data
    get_country_population
    get_country_births
    get_country_deaths
}

function change_coutry_to_fit_pattern() 
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

function check_country_on_the_list()
{
    grep $COUNTRY "$COUNTRY_LIST_FILE"
    [[ $? -eq 0 ]] && FOUND_COUNTRY="TRUE" || FOUND_COUNTRY="FALSE"
}

function update_country_data()
{
    wget -O "$COUNTRY_POPULATION_FILE" "$MAIN_URL"/"$COUNTRY"
}

get_country_list()
{
    wget -O "$COUNTRY_LIST_FILE" "$MAIN_URL"
}

MAIN_URL="https:://countrymeters.info/en"

COUNTRY_POPULATION_FILE="/tmp/country_population.$$"
COUNTRY_LIST_FILE="/tmp/country_list.$$"

FOUND_COUNTRY="FALSE"
COUNTRY="NONE"
COUNTRY_POPULATION=0
COUNTRY_BIRTHS=0
COUNTRY_DEATHS=0

MENU_LIST=("Choose specific country population statistics" "Exit")
MENU="."

get_country_list
menu

exit 0 
