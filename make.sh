if [ ! -d tmp ]; then
	mkdir tmp
fi

# for i in cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan aim65 sym1 worzbasic; do
for i in  worzbasic; do

echo $i
../cc65/bin/ca65 -D $i msbasic.s -o tmp/$i.o &&
../cc65/bin/ld65 -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl -m tmp/$i.map

done

