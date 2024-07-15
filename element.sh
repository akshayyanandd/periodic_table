#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

NOTFOUND() {
    echo "I could not find that element in the database."
}

if [[ -z "$1" ]]; then
    echo "Please provide an element as an argument."
    exit 1
fi

case $1 in
    *[!0-9]*)
        if [[ $1 =~ ^[a-zA-Z]$ ]]; then
            # If input is a symbol
            symbol=$1
            name=$($PSQL "SELECT name FROM elements WHERE symbol='$symbol'")
            atomic_number=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$symbol'")
        else
            # If input is a name
            name=$1
            symbol=$($PSQL "SELECT symbol FROM elements WHERE name='$name'")
            atomic_number=$($PSQL "SELECT atomic_number FROM elements WHERE name='$name'")
        fi
        ;;
    *[0-9]*)
        # If input is an atomic number
        atomic_number=$1
        symbol=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$atomic_number")
        name=$($PSQL "SELECT name FROM elements WHERE atomic_number=$atomic_number")
        ;;
esac

# Check if the element exists
if [[ -z "$name" || -z "$symbol" ]]; then
    NOTFOUND
    exit 1
fi

# Get additional properties
type=$($PSQL "SELECT type FROM properties INNER JOIN types ON properties.type_id=types.type_id WHERE atomic_number=$atomic_number")
atomic_mass=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$atomic_number")
melting=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$atomic_number")
boiling=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$atomic_number")

# Output the information
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting celsius and a boiling point of $boiling celsius."
