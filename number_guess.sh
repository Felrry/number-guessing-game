#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Getting random number
RANDOM_NUM=$(( RANDOM%1001 ))

#Asking user for an username
echo "Enter your username:"
read NAME

#get username from db
USER_NAME=$($PSQL "SELECT * FROM users WHERE user_names = '$NAME'")

if [[ -z $USER_NAME ]]
then
  #If the username doesn't exist
  echo "Welcome, $NAME! It looks like this is your first time here."
  
  #Get username
  INSERT_USERNAME_USERS=$($PSQL "INSERT INTO users(user_names, games_played, best_game) VALUES('$NAME', 0, 0)")
else
  #If username does exist
  echo $USER_NAME | while IFS="|" read USER_ID USER_NAMES GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

#Guess the secret numb
echo "Guess the secret number between 1 and 1000:"
read USER_NUMB

#Guessing the secret number
NUMBER_OF_GUESSES=1
#echo $RANDOM_NUM
until [[ $USER_NUMB == $RANDOM_NUM ]]
do
  if [[ ! $USER_NUMB =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $USER_NUMB -gt $RANDOM_NUM ]]
    then
      echo "It's lower than that, guess again:"
    else 
      echo "It's higher than that, guess again:"
    fi
  fi
  (( NUMBER_OF_GUESSES ++ ))
  read USER_NUMB
done

UPDATE_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = (games_played + 1) WHERE user_names = '$NAME'")
UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE user_names = '$NAME' AND (best_game > $NUMBER_OF_GUESSES OR best_game = 0)")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUM. Nice job!"
