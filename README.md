# Gollum Caves

This is an enterprise Wiki.  It is designed to work with Markdown for wiki files and several
editors to edit all files of a git repo in the wiki.  

## Directory Structure

- **wiki/** - contains wikis here
- **wiki/wiki/home** - basic wiki
- **wiki/wiki/skeleton** - skeleton wiki for new user's 'me' wiki
- **wiki/<user>/me**

If we talk about a wiki here, it is actually a bare repository

## Technology

It uses markdown-it for rendering.

## TODO

- First maybe start with refusing to post/uplaod files larger
  than 5MB

- second store them automatically on webdav accessible folder
  - what to do with versions?

- Create DAV endpoints which store data to wiki
- https://gionkunz.github.io/chartist-js/index.html
