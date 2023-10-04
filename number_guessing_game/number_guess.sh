#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"
RANDOM_NUMBER=$((RANDOM % 1000 + 1))

GUESS() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # read guess
  echo -e "\nGuess the secret number between 1 and 1000:"
  read USER_GUESS

  # if guess isn't an integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    GUESS "That is not an integer, guess again:"
  else  
    TRIES=0;
    # loop to check and count guesses
    while [[ $USER_GUESS -ne $RANDOM_NUMBER ]]
    do
      # if guess is high
      if [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
      then
        ((TRIES++))
        echo -e "\nIt's lower than that, guess again:"
        read USER_GUESS
      # if guess is low
      elif  [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
      then
        ((TRIES++))
        echo -e "\nIt's higher than that, guess again:"
        read USER_GUESS
      fi
    done
    # if guess is correct  
    ((TRIES++))
    if [[ $BEST_GAME -eq 0 || $BEST_GAME -gt $TRIES ]]
    then
      UPDATE_RECORD=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $TRIES WHERE username = '$USERNAME'")
    else
      UPDATE_RECORD=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
    fi
    echo -e "\nYou guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  fi
}

# read username
echo -e "\nEnter your username:"
read USERNAME

# check database for user
USER_RECORD=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")

# if user doesn't exist
if [[ -z $USER_RECORD ]]
then
  # create new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GUESS
else
  # display user game history
  echo "$USER_RECORD" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
  GUESS
fi