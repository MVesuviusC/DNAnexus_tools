#!/usr/bin/bash

main() {
    dx-download-all-inputs

    mkdir -p out/outdir
    ls ${input_path[@]} -lh

    md5sum ${input_path[@]} \
        > out/outdir/${outname}_md5sum_${DX_JOB_ID}.txt

    dx-upload-all-outputs
}
