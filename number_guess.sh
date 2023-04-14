#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# input username
echo "Enter your username:"
read USERNAME

# query available users
AVAILABLE_USRS=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
#echo $AVAILABLE_USRS

# query games count
GM_COUNT=$($PSQL "SELECT COUNT(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")

# query guesses count
GS_COUNT=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")

# if user not available
if [[ -z $AVAILABLE_USRS ]]
then
  # insert new user
  INSERT_USR=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  #GAME
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # if user exist
  echo "Welcome back, $USERNAME! You have played $GM_COUNT games, and your best game took $GS_COUNT guesses. "
  #GAME
fi

# random number
N=$(( RANDOM % 1000 + 1 ))
#echo $N

GUS=1

echo "Guess the secret number between 1 and 1000:"

while read NUM
do
  # if input not integer
  if [[ ! $NUM =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again: "
  # if input greater than random
  else
    if [[ $NUM -eq $N ]]
    then
      break;
    else
      if [[ $NUM -gt $N ]]
      then
        echo "It's lower than that, guess again: "
      # if input less than random
      elif [[ $NUM -lt $N ]]
      then
        echo "It's higher than that, guess again: "
      fi
    fi
  fi
  GUS=$(( $GUS + 1 ))
done

if [[ $GUS ]]
then
  echo "You guessed it in $GUS tries. The secret number was $N. Nice job!"
fi

# insert gueeses count
USR_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERT_GUS=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USR_ID, '$GUS')")

