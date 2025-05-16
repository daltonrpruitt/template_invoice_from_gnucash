#!/bin/bash
# This script asks for an invoice number, passes that to gcinvoice for LaTeX, makes that into a new .tex file
# and then makes a .pdf file with the invoice number and date in the file name.
# The user is then prompted to open the pdf file.
#
# Fill in the location of your GnuCash-database and your template below, as well as where you want your invoices
# to be placed.

set -e

clear

echo "Fill in invoice number"

read INVOICE_NUMBER

DATUM=$(date +%Y-%m-%d)

# Check if INVOICE_NUMBER is a number
case $INVOICE_NUMBER in 
    CN[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) echo "Invoice number: "$INVOICE_NUMBER, date: $DATUM ;; # Format is 'CN<customer number>-<last two digits of year>-<invoice number for customer this year>'
    *) echo "${INVOICE_NUMBER} is not a valid invoice ID. Try again."; exit 1  ;;
esac

# Fill in the location of your GnuCash-database below:
GNUCASHDATABASE=$(cat location_of_gnucashdatabase.txt)

# Fill in the location of your template below:
GCINVOICETEMPLATE="/location/of/template.tex"

# Fill in where you want your created invoices to be placed below:
INVOICES_DIR="invoices"

uv run create_gcinvoice -g "$GNUCASHDATABASE" -t "$GCINVOICETEMPLATE" -o "$INVOICES_DIR"/Invoice_"$INVOICE_NUMBER"_"$DATUM".tex  $INVOICE_NUMBER

echo File made: "$INVOICES_DIR"/Invoice_"$INVOICE_NUMBER"_"$DATUM".tex

# Make .pdf file
# Filter all output except errors
lualatex -shell-escape -file-line-error -synctex=1 -interaction=nonstopmode -output-directory="$INVOICES_DIR" "$INVOICES_DIR"/Invoice_"$INVOICE_NUMBER"_"$DATUM".tex
# | grep ".*:[0-9]*:.*"

echo File made: "$INVOICES_DIR"/Invoice_"$INVOICE_NUMBER"_"$DATUM".pdf

# Repress annoying Evince errors
alias evince='evince 2> >( grep -v "evince.*WARNING" >&2 )'

# Ask if user wants to open pdf file
read -p "Would you like to open the pdf file? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    evince "$INVOICES_DIR"/Invoice_"$INVOICE_NUMBER"_"$DATUM".pdf 2> >( grep -v "evince.*WARNING" >&2 ) # do dangerous stuff
fi
