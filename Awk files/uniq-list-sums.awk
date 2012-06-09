# OVERVIEW
#(1) Generate list of unique values from column_a.
#(2) Generate a sum of rows from column_b for each unique value, where the rows chosen for each sum
#    contain the unique value on column_a.

#CONFIGURE HEADINGS
BEGIN {
  FS=",";                                             #field saparator is a comma in csv files
  #COLUMN_A_HEADING = "heading2"                      #will be assigned from batch file command prompt
  #COLUMN_B_HEADING = "heading4"                      #will be assigned from batch file command prompt
}

#ASSIGN COLUMNS TO VARIABLES ACCORDING TO HEADINGS
NR==1 {                                               #NR means record (or row) number
  for (x=1; x<=NF; x++) {
    if ($x ~ COLUMN_A_HEADING) column_a = x;
    if ($x ~ COLUMN_B_HEADING) column_b = x;
  }
  next;
}

#ASSIGN UNIQUE LIST
{
  if ($column_a != "") unique_list[$column_a]++;
}

#GENERATE SUMS
{
  for (i in unique_list) {
    if ($column_a ~ i) sums[i] += $column_b;
  }
}

END {
  print COLUMN_A_HEADING "," COLUMN_B_HEADING;
  print "FILENAME," FILENAME_FOR_AWK
  for (i in unique_list) print i "," sums[i];
}