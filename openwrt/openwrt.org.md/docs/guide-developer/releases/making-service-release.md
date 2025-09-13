# How to create a service release

See also [release-process](/docs/guide-developer/releases/release-process "docs:guide-developer:releases:release-process") for more general guidance.

## 0) Prerequisites

- Fetch maintainer scripts from [https://git.openwrt.org/maintainer-tools.git](https://git.openwrt.org/maintainer-tools.git "https://git.openwrt.org/maintainer-tools.git")
- Ensure that GPG and usign keys are published and working according to [https://openwrt.org/docs/guide-user/security/keygen](https://openwrt.org/docs/guide-user/security/keygen "https://openwrt.org/docs/guide-user/security/keygen")

## 1) Prepare release tag

- Fetch pristine source tree, best do a new local clone, e.g.
  
  ```
  git clone git@git.openwrt.org:openwrt/openwrt.git
  git checkout openwrt-24.10
  ```
  
  - Replace branch name with appropriate one
- Place `maketag.sh` script from maintainer repo into the clone
- Execute `./maketag.sh -k 818021EBB6C9ECDA -v 24.10.0`
  
  - Replace key ID and version number with appropriate values
- Review auto generated commits with `git log -p -2`
  
  - Should show one setting adjustment and one setting revert commit
- Review auto generated tag with `git show v24.10.0`
  
  - Should show a git tag with associated GPG info and commit references
  - Replace version number accordingly
- Compare the files changed automatically with a previous tag
  
  - `git diff v24.10.0-rc7 v24.10.0 -- feeds.conf.default include/version.mk package/base-files/image-config.in version version.date`
- Check the signature on the tag with `git verify-tag -v v24.10.0`
  
  - Should show “Good signature from &lt;your name&gt;
- Push auto generated commits and tag to the remote:
  
  ```
  git push origin openwrt-24.10
  git push --follow-tags origin refs/tags/v24.10.0:refs/tags/v24.10.0
  ```
  
  - Replace version numbers and branch name accordingly
  - Review [https://git.openwrt.org/?p=openwrt/openwrt.git;a=tags](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dtags "https://git.openwrt.org/?p=openwrt/openwrt.git;a=tags")

## 2) Trigger builds

- Log into [https://buildbot.openwrt.org/images/#/builders/119](https://buildbot.openwrt.org/images/#/builders/119 "https://buildbot.openwrt.org/images/#/builders/119")
  
  - Use credentials provided by admin
- Open the “Builds → Builders” page
  
  - Select `00_force_build` builder
  - Click on `Force builds` button at the top of the page
- Fill out the form
  
  - Enter your name at `Your name` input box ![:-)](/lib/images/smileys/smile.svg)
  - Enter for example “Trigger release builds” as reason
  - Select Git tag you want to build from `Build tag` list
  - Click “Force Build”
- Review buildbot activity in waterfall view

## 3) Create changelogs

- Copy `make-changelog.pl` from maintainer repo into the local clone
  
  - The script needs the perl module JSON.pm, install `libjson-perl` and `libtext-csv-perl` on Debian
- Execute `./make-changelog.pl v24.10.0..v24.10.1`
  
  - Replace version numbers accordingly
  - Revision range should cover all commits since last release
  - Suggest to redirect stdout to a file
- Copy resulting change log into [https://openwrt.org/releases/24.10/changelog-24.10.0](https://openwrt.org/releases/24.10/changelog-24.10.0 "https://openwrt.org/releases/24.10/changelog-24.10.0")
  
  - Replace base and minor versions accordingly
  - Take care to preserve the first introductory paragraph in the wiki pages
  - Ideally use a prior change log page as template

## 4) Update release information page

- Once the release builds are finished and uploaded to [https://downloads.openwrt.org/releases/24.10.0/targets/](https://downloads.openwrt.org/releases/24.10.0/targets/ "https://downloads.openwrt.org/releases/24.10.0/targets/") ...
- ... head to release series parent page at [https://openwrt.org/releases/24.10/start](https://openwrt.org/releases/24.10/start "https://openwrt.org/releases/24.10/start")
  
  - Replace base version accordingly if needed
- Update timeline and latest version number, links etc. to point to the latest release
- Start preparing release notes at [https://openwrt.org/releases/24.10/notes-24.10.0](https://openwrt.org/releases/24.10/notes-24.10.0 "https://openwrt.org/releases/24.10/notes-24.10.0")
  
  - Replace version accordingly
  - Mention most important changes since last release
  - Use old release note pages as template
  - Good technique is to skim through detailed change log and taking note of outstanding commits or series of commits
  - Add redirect for ToH [toh\_maintenance](/wiki/internal/toh_maintenance#add_new_release "wiki:internal:toh_maintenance")

## 5) Update ToH to new release

See [Update ToH to new release](/wiki/internal/toh_update_to_new_release "wiki:internal:toh_update_to_new_release")

## 6) Announce

- Write an announcement to the mailing lists
  
  - Use [http://lists.infradead.org/pipermail/openwrt-devel/2017-October/009401.html](http://lists.infradead.org/pipermail/openwrt-devel/2017-October/009401.html "http://lists.infradead.org/pipermail/openwrt-devel/2017-October/009401.html") as template
- Write an announcement in the forum
  
  - All forum users in the [developer, moderator or admin group](https://forum.openwrt.org/g "https://forum.openwrt.org/g") can create new topics in this forum category
  - Use [https://forum.openwrt.org/t/lede-v17-01-4-service-release/7573](https://forum.openwrt.org/t/lede-v17-01-4-service-release/7573 "https://forum.openwrt.org/t/lede-v17-01-4-service-release/7573") as template
  - “Pin” the topic for 4-8 weeks
- Update references to the most recent release on the following services:
  
  - Update IRC channel topics (ping rmilecki)
  - Update [https://sysupgrade.openwrt.org/](https://sysupgrade.openwrt.org/ "https://sysupgrade.openwrt.org/") (ping aparcar)
  - Update [https://downloads.openwrt.org](https://downloads.openwrt.org "https://downloads.openwrt.org") page (ping jow)
