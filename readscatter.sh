for filename in PBSout/one_out_av-*
do
   tail -n 11 $filename | head -n 1 >> scatter.txt
done
