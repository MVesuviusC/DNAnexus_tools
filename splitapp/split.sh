#!/usr/bin/bash

main() {
    echo "test"

    dx-download-all-inputs

    mkdir -p out/splitOut/

    ls ${input_path[@]} -lh

    parallel 'split --numeric-suffixes \
              -a 4 \
              -b ${splitSize} \
              {} \
              out/splitOut/{/}; \
              md5sum out/splitOut/{/}[0-9]* \
              > out/splitOut/{/}_md5.txt' \
              ::: ${input_path[@]}

    dx-upload-all-outputs
}
