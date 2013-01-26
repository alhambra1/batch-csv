function isNum(x){return(x==x+0)}

function excelColumnToNum(excel_column) {
  string_position=length(excel_column);
  output_number=0;
		  
  for (j=0; j<length(excel_column); j++) {
    base_string=tolower( substr(excel_column, string_position, 1) );
    string_position--;
    power=j;
    base_number=match(letters, base_string);
    output_number += base_number*(26^power);
  }
  return output_number;
}

function makeRange(lower, upper) {
  range = "";
  lower = lower/1;
  upper = upper/1;
  for(c=lower; c<=upper; c++) {
    range = range "$" c;
    if (c < upper) range = range ",";
  }
  return range;
}

#/1/, /1/
{	
  letters="abcdefghijklmnopqrstuvwxyz";
  split($0, input_only, "DELIMITER");
  line = input_only[2];
  line_length = length(line);
  position_in_line = 1;
  new_line = "";
  tmp = "";
  tmp_number = "";
  tmp_string = "";
  tmp_lower = "";
  tmp_upper = "";
  tmp_range = "";
  error = 0;
  isRange = 0;
  isString = 0;
  isNumber = 0;

  for (i=0; i<line_length; i++) {
    tmp = tolower(substr(line, position_in_line, 1));
  
    if (isNum(tmp) == 1 || tmp == 0) {
      if (isString == 1) {
        print "Please do not mix letters and numbers for the same column value.";
        error = 1;
        break;
      }
      else if (position_in_line == line_length) {
        if (isRange == 0) {
          tmp_number = tmp_number tmp;
          if (tmp_number == 0) {
            print "Please enter column values as numbers greater than zero or as letters.";
            error = 1;
            break;
          }
          else new_line = new_line "$" tmp_number;
        }
        else {
          tmp_upper = tmp_number tmp;
          tmp_range = makeRange(tmp_lower, tmp_upper)
          new_line = new_line tmp_range;
        }
      }
      else {
        isNumber = 1;
        tmp_number = tmp_number tmp;
        position_in_line++;
      }
    }
    else if (tmp != "-" && tmp != ",") {
      if (line ~ /[[$(^|.]/) {
        print "Please enter only numbers, letters, commas, or dashes for column input.";
        error = 1;
        break;
      }
      else if (match(letters, tmp) == 0) {
        print "Please enter only numbers, letters, commas, or dashes for column input.";
        error = 1;
        break;
      }
      if (isNumber == 1) {
        print "Please do not mix letters and numbers for the same column value.";
        error = 1;
        break;
      }
      else if (position_in_line == line_length) {
        if (isRange == 0) {
          tmp_string = tmp_string tmp;
          number = excelColumnToNum(tmp_string);
          new_line = new_line "$" number;
        }
        else {
          tmp_upper = tmp_string tmp;
          tmp_upper = excelColumnToNum(tmp_upper);
          tmp_range = makeRange(tmp_lower, tmp_upper);
          new_line = new_line tmp_range;
        }
      }
      else {
        isString = 1;
        tmp_string = tmp_string tmp;
        position_in_line++;
      }
    }
    else if (tmp == "-") {
      if (tmp_string == "" && tmp_number == "") {
        print "Please enter a starting value for range.";
        error = 1;
        break;
      }
      else if (position_in_line == line_length) {
        print "Please end column input with either a letter or a number.";
        error = 1;
        break;
      }
      else if (position_in_line == 1) {
        print "Please start column input with either a letter or a number.";
        error = 1;
        break;
      }
      else if (tmp_string != "" || tmp_number != "") {
        isRange = 1;
        if (tmp_string != "") {
          tmp_lower = excelColumnToNum(tmp_string);
          tmp_string = "";
          isString = 0;
        }
        else {
          tmp_lower = tmp_number;
          tmp_number = "";
          isNumber = 0;
        }
        position_in_line++;
      }
    }
    else if (tmp == ",") {
      if (position_in_line == line_length) {
        print "Please end column input with either a letter or a number.";
        error = 1;
        break;
      }
      else if (position_in_line == 1) {
        print "Please start column input with either a letter or a number.";
        error = 1;
        break;
      }
      else if (tmp_string == "" && tmp_number == "" && tmp_upper == "") {
        print "Please avoid two commas without a value or range in between.";
        error = 1;
        break;
      }
      else if (isRange == 0) {
        if (isString == 1) {
          number = excelColumnToNum(tmp_string);
          new_line = new_line "$" number;
          if (position_in_line < line_length) new_line = new_line ",";
          isString = 0;
          tmp_string = "";
          position_in_line++;
        }
        else if (isNumber == 1) {
          new_line = new_line "$" tmp_number;
          if (position_in_line < line_length) new_line = new_line ",";
          isNumber = 0;
          tmp_number = "";
          position_in_line++;
        }
      }
      else if (isRange == 1) {
        if (isString == 1) {
          tmp_upper = excelColumnToNum(tmp_string);
          tmp_string = "";
          isString = 0;
        }
        else {
          tmp_upper = tmp_number;
          tmp_number = "";
          isNumber = 0;
        }
        tmp_range = makeRange(tmp_lower, tmp_upper);
        new_line = new_line tmp_range ",";
        position_in_line++;
        isRange = 0;
      }
    }
  }
}

{if (error == 0) print new_line}