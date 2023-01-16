#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate data from tables
echo $($PSQL "TRUNCATE teams, games");

# reset ID numbering
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1");
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1");

# loop to insert teams
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $YEAR != year ]]
  then

    # check if winner alreay in table
    WINNER_IN_TEAMS=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not, insert it
    if [[ -z $WINNER_IN_TEAMS ]]
    then
      WINNER_INSERTION_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')");
      echo Team $WINNER inserted into teams.
    fi

    # check if opponent already in table
    OPPONENT_IN_TEAMS=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not, insert it
    if [[ -z $OPPONENT_IN_TEAMS ]]
    then
      OPPONENT_INSERTION_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')");
      echo Team $OPPONENT inserted into the teams table.
    fi

  fi
done

# loop to insert match results
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $YEAR != year ]]
  then

    # get id of the teams
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'");
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'");
    
    # insert data into the games table
    GAME_INSERTION_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OGOALS)");

    echo "$ROUND game ($WINNER vs $OPPONENT) from the $YEAR world cup inserted into the games table."
  fi
done