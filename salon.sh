#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n~~~~~ MY SALON ~~~~~\n'

SERVICES_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi 
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  # display available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
  SERVICES_MENU "I could not find that service. What would you like today?"
  else
  # get user phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # check if it exists
  if [[ -z $CUSTOMER_NAME ]]
  then
  # if it doesn't ask for a name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # add phone number and name to customers table
  NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get customer_id 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your cut, $(echo "$CUSTOMER_NAME" | sed 's/^ *//;s/ *$//')?"
  read SERVICE_TIME
  NEW_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES('$SERVICE_ID_SELECTED', '$CUSTOMER_ID', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo "$SERVICE_NAME" | sed 's/^ *//;s/ *$//') at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | sed 's/^ *//;s/ *$//')."
  fi
}

SERVICES_MENU "Welcome to My Salon, how can I help you?"