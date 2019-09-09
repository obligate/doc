## Awk Sum,Count, and Average with Arrays
### Sample File
+ Command:
`$ cat file1.txt `

+ Output:

```
Alex,147,1
Brian,056,7
Nanda,559,2
Lisa,221,0
Nanda,268,2
Alex,200,5
Alex,408,8
```

### a[$1] registers the first field of the lines seen in the associative-array "a" (arrays are always associative in Awk) 
```
Command:
$ awk -F "," '{a[$1]} END {for (i in a) print i}' file.txt 

Output:
Nanda
Lisa
Alex
Brian
```

### Count of first field, sum of 2nd field, sum of 3rd field group by each first field
```
Command:
$ awk -F "," '{a[$1]++; b[$1]+=$2; c[$1]+=$3 } END {for (i in a) print i,a[i],b[i],c[i]}' file1.txt 

Output:
Nanda 2 827 4
Lisa 1 221 0
Alex 3 755 14
Brian 1 56 7
```

### Sum of 2nd field, sum of 3rd field group by each first field

```
Command:
$ awk -F "," '{a[$1]+=$2; b[$1]+=$3 } END {for (i in a) print i,a[i],b[i]}' file1.txt 

Output:
Nanda 827 4
Lisa 221 0
Alex 755 14
Brian 56 7
```

### Sum of 2nd field, sum of 3rd field group by each first field, same as ii)

```
Command:
$ awk -F "," '{a[$1]+=$2; b[$1]+=$3 } END {for (i in b) print i,a[i],b[i]}' file1.txt 

Output:
Nanda 827 4
Lisa 221 0
Alex 755 14
Brian 56 7
```


## sample
+ 统计solr请求中，url被调用的次数，以及流量情况，按照流量降序`sort -nrk 3`,其中-k指定排序的字段，-r是降序
```
cat  solr.log|awk 'NR>1{a[$7]++;b[$7]+=$10}END{for(i in a) print i,a[i],b[i]/1024/1024|"sort -nrk 3"}'|wc -l
```