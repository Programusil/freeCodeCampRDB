#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --tuples-only -c"
ELEMENT=$1

if [[ -z $ELEMENT ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $ELEMENT =~ ^[0-9]+$ ]]
  then
    SELECTED_ELEMENT=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = '$ELEMENT'")
  else
    SELECTED_ELEMENT=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$ELEMENT' OR name = '$ELEMENT'")
  fi

  if [[ -z $SELECTED_ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$SELECTED_ELEMENT" | while read TYPENBR BAR ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR MASS BAR MELTING BAR BOILING BAR TYPE
    do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius." 
    done
  fi
fi