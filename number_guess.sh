#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\n~~~ Number Guessing Game ~~~ \n"

# Generate random number for user to guess
RANDOM_NUM=$(( $RANDOM%1000 + 1 ))
echo "Random number: $RANDOM_NUM"
TRIES=1

# Get user's info
echo "Enter your username:" 
read USERNAME

# Check username in the db
CHECK_USERNAME=$($PSQL "SELECT username FROM user_info WHERE username = '$USERNAME'")

# If username is not in the db
if [[ -z $CHECK_USERNAME ]]
then
  # Insert new user in the db
  USER_INSERT_RESULT=$($PSQL "INSERT INTO user_info(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
else
  # Retrieve user's info
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE username = '$USERNAME'")

  # Output welcome message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Ask for user's guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS
  
while [[ $USER_GUESS != $RANDOM_NUM ]]
do
  # If user inputs a valid INT
  if [[ $USER_GUESS =~ ^[1-9][0-9]{0,3}$ ]]
  then
    TRIES=$(( $TRIES + 1))
    if [[ $USER_GUESS -lt $RANDOM_NUM ]]
    then      
      echo "It's higher than that, guess again:"
    elif [[ $USER_GUESS -gt $RANDOM_NUM ]]
    then
      echo "It's lower than that, guess again:"
    fi
    read USER_GUESS
  else
  # If user inputs an invalid guess
    echo "That is not an integer, guess again:"
    read USER_GUESS
  fi
done

# If the user guess correctly
# echo "Previous guess: $USER_GUESS"
TRIES=$(( $TRIES + 1))
echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUM. Nice job!"

# Update db
# First time playing
if [[ $GAMES_PLAYED -eq 0 ]]
then
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  UPDATE_GAMES=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
  UPDATE_BEST=$($PSQL "UPDATE user_info SET best_game = $TRIES WHERE username = '$USERNAME'")
else
  # If user beats their record
  if [[ $TRIES -lt $BEST_GAME ]]
  then
    GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
    UPDATE_GAMES=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
    UPDATE_BEST=$($PSQL "UPDATE user_info SET best_game = $TRIES WHERE username = '$USERNAME'")
  else
    # If user does not beat their record
    UPDATE_GAMES=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
  fi
fi

