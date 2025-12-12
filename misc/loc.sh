#!/bin/sh

dir=${1:-.}
echo Counting lines in `realpath $dir`:

# The strange full path is just for me (or those who also have it this way), 
# to disambiguate from Win's FIND.EXE in a mixed env.:
/usr/bin/find $dir -type f -a \( -name '*.sh' -o -name '*.cmd' -o -name '*akefile*' -o -name 'run_*' \) -a -exec wc -l \{\} \; \
	| awk '{ total += $1 } END{ print total }'

exit

#!!!
#!!!
#!!!
echo /usr/bin/find
	/usr/bin/find $dir -type f -a \( -name '*.sh' -o -name '*.cmd' -o -name '*akefile*' -o -name 'run_*' \) -a -exec wc -l \{\} \;
#!!
#!! WOW, this differs quite a bit, who knows why!
#!! E.g. it can't find build-gcc.sh, defs.sh etc.! :-ooooo
echo BB:
	busybox  find $dir -type f -a \( -name '*.sh' -o -name '*.cmd' -o -name '*akefile*' -o -name 'run_*' \) -a -exec wc -l \{\} \;
