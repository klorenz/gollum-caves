# Repository Indexer

Repository Indexer must be able to create an index from 0, having a bare
repository.  In this case, there may be no collection for consulting
default settings.

- Indexer walks over all commits, starting at the first.

  - Create new index-docs for each changed file in that commit.

  - All not changed files in that commit, are updated and commit SHA
    is added to index-doc.

  - All removed files are not considered and do not get the new commit SHA

- Access field is merged from collection wiki and page using
  setting-merge-policy.  Resulted list is stored as Access.

- Deny field is merged from collection wiki and page using
  setting-merge-policy.  Resulted list is stored as deny.

## Index Document `page`

## Index Document `image`

Basic data should be taken from EXIF information, if present

```yaml
```

## Index Document `video`

I do not know, if there are any meta informations.

## Index Document `audio`

use tags

## Index Document `file`

other documents

## Index Document `commit`

```yaml
commit: <list of sha1>
author: <author of last commit>
authors: <list of authors>
last_modified: <date of last modification>
```

## Index Queries

All index query add all roles and groups a person is in to the query as:

  (<access field not present> OR access:<role1> OR access:<role2>) AND NOT
  (deny:<role1> OR deny:<role2>)

Deny rules over access.  If a big group is denied, a smaller allow is not,
person of both groups will be denied.  Then rather the big group should not
be in deny group.
