# DNA nexus apps

These are a couple of DNA nexus apps that I wrote. To use them, you'll need to have the dnanexus SDK installed. See https://documentation.dnanexus.com/downloads for help with that.

## md5app
This app calculates md5sums for files and writes the results out to a file

## splitapp
This app takes input file and uses the unix split command to split them into 

## Example of installing the md5app for a project
```
# go to the directory of the app you're installing with the source code
cd md5app

# Initialize the dnanexus environment wherever you installed it
# Your path will likely be different
source ~/virtualEnvs/dnanexus/bin/activate

# login to server, choose which project to attach to
dx login

# build app from the json and associated file(s)
dx build

# Turn off environment
deactivate
```

After this you can go to your project on [DNAnexus](https://platform.dnanexus.com) and use the app from there. To make things go faster, when specifying your input files, turn on `Enable Batch` so each file is run on it's own server in parallel instead of one at a time.


## Downloading from DNAnexus
I had a lot of trouble downloading large files from DNAnexus. My downloads kept getting disconnected part way through and I hand to manually restart the downloads many, many times. I couldn't figure out why this was happening so to get around this I came up with a workaround.

>Note that this is all designed to run on unix.

I used the splitapp (above) to split the large files into 1Gb pieces and then downloaded a file from DNAnexus with links to the downloads. I calculated md5sums with the md5app and downloaded the file that had the md5sums.

I then ran `prepDownloadFile.pl` to generate a file I could use with `dnaNexusDl.pl` to automatically retry the downloads. The first script just matches up the download link to the md5sums and the second script takes the matching md5sum and link and retries the download until it works and checks the md5sum.


```
# Match up md5sums and links
perl prepDownloadFile.pl \
  --linkFile DNAnexus_export_urls-20210930-084226.txt \
  --md5File allMd5.txt \
    > downloadFile.txt

### loop over all links and download each in turn
for i in $(seq 1 $(wc -l downloadFile.txt | cut -d " " -f 1))
do
    currentLink=${linkArray[1]}
    currentMd5=${md5Array[1]}

    echo ${i} ${currenLink}

    perl ~/scripts/dnaNexusDl.pl \
        --link ${currentLink} \
        --md5 ${currentMd5}
done
```

My cluster uses slurm, so I wrote a sbatch file (`forceDownload.sh`) to automate this for me. To use this, change:

-   `--array=0-xx` argument so that `xx` is equal to the number of links minus 1
-   `--account=accountHere` to include your account or delete this line if you don't need it

Then run the shell script. This script will look for downloadFile.txt and download several at once to the current working directory.

```
### Or download a bunch at once using slurm
sbatch forceDownload.sh
```

This all assumes that you have unique file names for the files you're downloading, so if that isn't the case you'll run into trouble and files will be overwritten.
