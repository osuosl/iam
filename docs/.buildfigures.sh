#!/bin/bash
for i in `find . -name *.dot | sed s/.dot//`; do
    dot -Tpng ${i}.dot > ${i}.png
    dot -Tsvg ${i}.dot > ${i}.svg
done

mv source/figures/*.{svg,png} source/_static/
