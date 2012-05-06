lfs-scrape
==========

Very simple ruby based scraper to populate a list of scripts for semi automated lfs builds

This is not intented to truly and fully automate the whole process, but rather make it easier for users familiar with the LFS build concept

to frequently adapt to the upstream version, while minimizing the changes to code.

This scraper will parse through the LFS website and dump any code section into shell scriptlets.

  *This will run the downloads concurrently, since they're from a wide range of servers it utilizes bandwidth much better and takes only a very fraction of the time compared to sequentially downloading the sources*

  > wget -O /dev/stdout http://www.linuxfromscratch.org/lfs/view/stable/wget-list | while read url; do   wget -bc $url; done

  *a very small script to run through the scripts of chapter 5*

  > #!/bin/bash -xe
  > rm -f /mnt/lfs/chapter05/00{1,2,3}*.sh
  > for s in /mnt/lfs/chapter05/*sh
  > do
  >  # this really only works with the bash shell
  >  bash -xe $s
  > done

