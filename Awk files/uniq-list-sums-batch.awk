BEGIN {
  FS=",";
  OFS=",";
  ind=1;
  num_elements=0
  max_length = 0;
  x=1;
  y=1;
}

{
  col1[x++] = $1;
  col2[y++] = $2;

  if ($0 ~ /DELIMITER/) {
    len = NR-ind;
    element_index[num_elements] = ind;
    element_length[num_elements] = len;
    num_elements++;
    ind = NR+1;
    if (len > max_length) max_length = len;
	}
}

END {
  for (i=0; i<max_length; i++) {
    for (j=0; j<num_elements; j++) {
      field = (j+1)*3-2;
      if (element_length[j] > i) { 
        $field = col1[element_index[j]+i];
        $(field+1) = col2[element_index[j]+i];
      }
      else {
        $field = "";
        $(field+1) = "";
      }
    }
	print;
  }
}
