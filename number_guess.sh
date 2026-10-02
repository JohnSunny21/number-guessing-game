#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Check if user exists in the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  # Insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Retrieve returning user stats
  GAMES_PLAYED=$($PSQL "SELECT count(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT min(number_of_guesses) FROM games WHERE user_id = $USER_ID")
  
  # Clean up whitespace if any
  GAMES_PLAYED=$(echo $GAMES_PLAYED | tr -d ' ')
  BEST_GAME=$(echo $BEST_GAME | tr -d ' ')

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_OF_GUESSES=1

# Game loop
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # Check if input is an integer using regex
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

# Save game result to database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"