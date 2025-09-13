# Revision number calculation

LEDE continues to use the svn-like rXXXX revision, but as source code is stored in git repository, the rXXXX revision needs to be calculated separately.

LEDE uses the shell script scripts/getver.sh for calculating the revision. It calculates the revision by counting the number of commits since the LEDE repository was initially cloned from Openwrt.

- The counting is not global, but is done separately for master and stable branches. E.g. currently 17.01 branch is at r3300 while master is at r3921.

## Convert between source revision and git commit hash

You can use ./scripts/getver.sh in your buildroot in four ways:

- Without arguments, it gives you current HEAD revision as “rxxxx-hash”. That is the normal use.
- If you give a version like “r3298” as an argument, it fetches you the git hash
- If you give a git hash as argument, it calculates the rxxxx revision for it
- If you give it its own output (“version string”) it will return the hash for the git commit

#### Example

```
$ git log --oneline
53fcaed1f7 image.mk: force kernel rebuild on every run
638ca50f3b kernel: Fix the incorrect i_nlink count after jffs2's RENAME_EXCHANGE operations.
47bf110cbb mac80211: backport an upstream fix for queue start/stop handling
a49503bbc7 sysntpd: restore support for peer-less (standalone) mode
1bdd23231b ar71xx: fix Wallys DR344 ethernet MAC addresses offsets
0cb669b469 ugps: fix and improve init script
0dcc4d239d kernel: update kernel 4.4 to 4.4.59

$ ./scripts/getver.sh 
r3300-53fcaed1f7

$ ./scripts/getver.sh 0cb669b469
r3295-0cb669b469

$ ./scripts/getver.sh r3296
1bdd23231b9de6f98b5c51360167abc7b5e92716
```

Recovering git commit from version string

```
lede_source$ git describe
v17.01.4-215-g05f0fac

lede_source$ ./scripts/getver.sh 
r2993+783-b9a408c

lede_source$ ./scripts/getver.sh r2993+783-b9a408c
05f0fac189984981e3f28288e44d9afdd088dd77
```
