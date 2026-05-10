# gitHooks

Scripts used by git-hooks in Galacticus repos.

## commit-msg

The `commit-msg` hook enforces [Conventional Commit](https://www.conventionalcommits.org) format.

## pre-commit

The `pre-commit` hook runs a number of checks on staged files:

* Fortran static analysis (e.g. empty constructors/destructors, duplicate variables in `constructorAssign` directives);
* bibliography (`.bib`) file validation;
* spell checking of LaTeX content;
* Python script compilation (`.py`);
* XML/XSD well-formedness, plus a check for non-ASCII characters;
* YAML linting (`.yml`, when [`yamllint`](https://yamllint.readthedocs.io) is available);
* compilation of Galacticus embedded XML and LaTeX fragments;
* detection of leftover debugging statements (e.g. `AJB HACK`) in Perl, Fortran, and C/C++ sources.

## pre-push

The `pre-push` makes you confirm if you really, really want to push directly to the `master|main` branch - think twice before you do.....

## License

Released under the [MIT License](LICENSE).
