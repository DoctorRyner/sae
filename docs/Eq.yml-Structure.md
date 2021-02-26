# Eq.yml structure

Eq.yml has all of the fields of ipkg config format except for `modules`, it also has a few new fields. We will overview only these changes and required fields. If you need information about all config fields, you can see them here (Search for the Config record) https://github.com/DoctorRyner/sae/blob/master/src/Sae/Types.idr#L44

* modules — no need to specify modules manually, they are all generated automatically
* target — the same as `--codegen` or `--cg` for `idris2` executable, by default `chez` is used
* ignoredModules — excludes listed modules from building
* sources — a list of external dependencies in the format:

```yaml
name: package-name
url: https://github.com/SomeAuthor/repo-name
version: v0.0.1
```

Where:

* name — is used for distinguishing packages
* url — can be any url, including a local path such as `./path/to/package`
* version — is a commit or a release tag

Required fields:

* package — the package name, note: this field is used as the name for the generated .ipkg file
* version — the package version, should be in the format `0.0.1`

To add a dependency from a source, you need to specify a `package name` and a `version` like this:

```yaml
depends:
- contrib
- package-name-0.0.1
```
