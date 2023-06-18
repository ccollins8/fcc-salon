#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ My Salon ~~~\n"

# get services
SERVICES=$($PSQL "select * from services")

DISPLAY_SERVICES () {
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
do
  echo "$SERVICE_ID) $SERVICE"
done

}

# display services
echo -e "\nWelcome to My Salon, how can i help you?"
DISPLAY_SERVICES
# take input from user
read SERVICE_ID_SELECTED

# get service they want
SERVICE_ID=$($PSQL "select service_id from services WHERE service_id = $SERVICE_ID_SELECTED")

# whjie not found
while [[ -z $SERVICE_ID ]]
do
  # list services again
  echo -e "\nI could not find that service. What would you like today?"
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "select service_id from services WHERE service_id = $SERVICE_ID_SELECTED")
done

# get customer info
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  # ask for customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
fi

# get appointment time
SERVICE_NAME=$($PSQL "select name FROM services WHERE service_id = $SERVICE_ID")
echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment row
CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone = '$CUSTOMER_PHONE'")
echo $CUSTOMER_ID
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")

# Final message to customer
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
