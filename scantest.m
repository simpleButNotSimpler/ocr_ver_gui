fileid = fopen('template.txt', 'r');
file = textscan(fileid, '%d %f %f','HeaderLines', 1, 'Whitespace',' \b\t:(,)');
fclose(fileid);