#!/bin/env fish

for d in */;
	cd $d;
	git pull origin master;
	cd ..;
end;
