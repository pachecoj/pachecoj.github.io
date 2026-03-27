echo -e "pachecoj@cs.arizona.edu" | convert -background none -density 196 -resample 300 -unsharp 0x.5 -font "Courier" text:- -trim +repage -bordercolor white -border 3 email.png
