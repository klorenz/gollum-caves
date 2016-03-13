<!-- ---
# consult [[]]

-->

# Wikifile Metadata

Metadata is used by indexer to build a [[Repository Index]].  You can add
metadata about a file, by adding

- a markdown page with frontmatter (or gollum-frontmatter)
- a json file
- a yaml file
- (more ? like cson?)

All of these can contain metadata and they are recognized as metadata if they
have `meta-about` key.


## meta-about

This must contain a URI, which can be either a relative
path or a absolute path (/wiki/<access>/<coll>/<wiki>/...) or a URL to any other
resource.

Indexer takes the data of that file (stored in meta-about) and adds this data
to this index document.


## Implicit meta data

From git there is coming following meta-data:

```yaml
commit: <sha1>
author: <author uid>
last_modified: <last modified>
```

There will be also a document for each commit (type `commit`), storing all the data on the
commit.

From a page there is coming following meta-data:

```yaml
outline:
  - headline 1
    - headline 2
    - headline 2

  - another headline 1
```

## Access control

For access control you can set `access` meta-data.  This can contain any role
or group, the person must complain or login-name.  In later index access, all
roles and groups of a person are part of the query, such that the person only
gets the data, it is allowed to see.

Apart from this page `access`, access control of wiki and collection are
consultet for setting this value.
