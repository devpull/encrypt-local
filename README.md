# encr_loc
Encrypt local resources(huge files > 10gb) with key &amp;&amp; public key

## Description
Runs recursively in directory. Encrypted file is registered in reg.lst by md5sum. Checks on every run.

## Dependencies on windows
* Git for windows 2.5.1

## Usage
silent.win.vbs - to run silently ```wscript "D:\path\to\encr_loc\silent.win.vbs"```
e.sh - main enc'ion file
d.sh - prompted fast decryption