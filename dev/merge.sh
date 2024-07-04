#!/bin/bash

outf="../Dropout.pde"
ver_str="// ver: 20240704"

echo $ver_str > $outf

for file in *.pde
do
    cat "$file" >> $outf
done
