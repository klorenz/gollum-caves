# Gollum Caves

This is an enterprise Wiki.  It is designed to work with Markdown for wiki files and several
editors to edit all files of a git repo in the wiki.  

**This is not yet for production use, not all concepts clear,  WYSIWYG Editor is still in work**
## Directory Structure

- **wiki/** - contains collections
- **wiki/wiki/me** - collection configuration wiki
- **wiki/wiki/home** - landing wiki
- **wiki/<user>/me** - user's configuration wiki
- **wiki/<group>/me** - groups's configuration wiki

Idea: have something like a template wiki

- **wiki/wiki/skeleton** - skeleton wiki for new user's 'me' wiki

If we talk about a wiki here, it is actually a bare repository

## Technology

- https://github.com/gollum/gollum
- http://jbt.github.io/markdown-editor
  - http://codemirror.net/
- https://github.com/markdown-it/markdown-it
- http://ckeditor.com
- http://rack.github.io/
- http://sinatrarb.com
- https://github.com/klorenz/ckeditor-markdown-wysiwyg
- https://github.com/georgi/rack_dav

It uses markdown-it for rendering.

## TODO

- Handle large files

  - First maybe start with refusing to post/uplaod files larger
    than 5MB

  - second store them automatically on webdav accessible folder
    - what to do with versions?

- Create DAV endpoints which store data to wiki

## Ideas

- https://gionkunz.github.io/chartist-js/index.html

- Use CKEditor to create workflows textually.

  Think of languages like https://knsv.github.io/mermaid/#mermaid or http://adrai.github.io/flowchart.js/
  or http://plantuml.com/, http://www.graphviz.org or even
  http://floppsie.comp.glam.ac.uk/Glamorgan/gaius/web/pic.html.

  For this think of a tabular defined workflow like (from http://foswiki.org/Extensions/WorkflowPlugin)

  |  *State*      | *Action* | *Next State*  | *Allowed*                        |
  |---------------|----------|---------------|----------------------------------|
  | APPROVED      | revise   | UNDERREVISION | QualityGroup                     |
  | UNDERREVISION | complete | WAITINGFORQM  | QualityGroup                     |
  | WAITINGFORQM  | approve  | WAITINGFORCTO | QualityManager                   |
  | WAITINGFORQM  | reject   | UNDERREVISION | QualityManager,QualityGroup      |
  | WAITINGFORCTO | approve  | APPROVED      | TechnicalDirector                |
  | WAITINGFORCTO | reject   | UNDERREVISION | TechnicalDirector,QualityManager |

  this can be easily transformed to Mermaid:

      APPROVED --> C{"member of QualityGroup?"}      -- revise   --> UNDERREVISION
      UNDERREVISION --> C{"member of QualityGroup?"} -- complete --> WAITINGFORQM
      ...

  Now think of a textual description

  ```
  - :role:`QualityGroup` can :action:`revise` an :state:`APPROVED` page to
    :next:`UNDERREVISION` state.
  - :role:`QualityGroup` can :action:`complete:` a page :state:`UNDERREVISION`
    to :next:`WAINTINGFORQM` state.
  ```
  This notation uses reStructuredText `role` syntax.  

  Following the http://pandoc.org/README.html#inline-code-attributes we can use
  ```
  - `QualityGroup`{.role} can `revise`{.action} an `APPROVED`{.state} page to
    `UNDERREVISION`{.next} state.
  ```

  Now thinking of CK Editor, you can mark an ordered list as workflow.  The
  Workflow has a specific view (non-editable content), which displays the
  graph to the text you have.  You simply add the text roles (styles) to
  the words and the flow chart is created on the fly!

  Same you can do with a table.


  | *State*       | *Allow Edit* | *Message*  |
  |---------------|----------|---------------|
  | UNDERREVISION | QualityGroup | This document is being revised.              |
  | APPROVED      | nobody       | This document has been approved for release. |
  | WAITINGFORQM  | nobody       | This document is waiting for approval by the Quality Manager. |
  | WAITINGFORCTO | nobody       | This document is waiting for approval by the CTO.|


  For this think of a textually represented workflow like


## Subscriptions

Subscriptions are maintained by each user.  They are metadata in
wiki page `<user>/me/subscriptions`:

~~~
    ```-yaml
    change:
        - collection/wiki/PageName
        - collection/wiki2/
    add:
        - some/wiki/
    delete:
        - some/wiki/Home
    ```
~~~

The user will be notified on

- change of `collection/wiki/PageName.md`
- on change of any page in `collection/wiki2/`
- if a page is added to `some/wiki/`
- if a page `some/wiki/Home.md` is deleted

```-yaml
Status: Draft
```

[ ] Implemented


## TODO

- need partials like in

  ~~~js
  Mustache.registerHelper("renderPartial", function(templateName) {
    return can.view.render(templateName, this)
  }
  ~~~

  Then define "Gollum::Editors" like `Gollum::Markups` Markup for each
  registered Type.

  Default type is `Gollum::Editor::Upload`

- Need partial template path, to be able to read templates from plugins

- Add default Page for any format.  Display Page lik

- What to do if you have `Page.svg` and `Page.md` and you request `Page`?

- define SVG as Markup

- Add "format" selector to new page.

- Finish Settings engine.

- Add ACL Lists.

- Add inline-code-attributes

- CKEditor

  - Add Gollum Links to CKEditor Markdown Transformer

  - Add Selector for gollum pages to CKEditor Link Dialog

  - Add Selector for gollum images (especially attachmens)
    to CKEditor Image Dialog

- Handle big files (start with deny upload of big files)

  Having https://github.com/cdunn2001/git-sym/wiki/Details in mind:

  - Create a simple script, which handles big files

  - For a big file, there is created a file ".get-<filename>.mak", which
    contains the rules how to create <filename>.  <filename> itself will
    be added to .gitignore file.

      git








- finish DAV Resource

- check for edit clashes on save

- Page Validator:

  - you should be able to add a page validator, which is run as hook in
    markup chain.  You can add validation records as frontmatter.  If one
    is not fulfilled, there is shown a corresponding message.

    This can be also checked using the server-based preview.

- Server Based Preview.  You should be able to select preview type between
  instant (fast, local on page) and server-based (a little delayed after
  changes)

- Configurable (per-wiki) threshold Setting for big files (maybe even by format, size)
  Big files must be creatable by something easy like make. (even on windows)

  They must be updated, if the file has been updated.  (If the hashed location changed)

- HTML import to Markdown


- other markdown editors: https://github.com/NextStepWebs/simplemde-markdown-editor/
- trumbowyg
- aloha
- http://epiceditor.com/
http://blog.netgusto.com/tag/wysiwyg/

| foo | bar |
|-----|-----|
