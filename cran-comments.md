## Test environments

* local: Windows 10, R 4.6.0
* GitHub Actions:
    * windows-latest, R release
    * macos-latest, R release
    * ubuntu-latest, R devel / release / oldrel-1
* win-builder: R devel, R release
* r-hub: windows / linux / macOS

## R CMD check results

0 errors | 0 warnings | 0 notes

## This is a new release

This is the first submission of `surveymerge` to CRAN. The package was
previously developed under the name `odkmerge` (never published to CRAN)
and has been renamed to better reflect its scope (relational survey
exports in general, not only ODK) and to avoid using the ODK trademark
in the package name. The previous name remains available as a deprecated
alias inside the package so existing scripts continue to run.

## Reverse dependencies

There are currently no reverse dependencies.
