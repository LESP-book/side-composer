# Full Width test fixture

This fixture is used only by the Side Composer system specs. It implements the
public Full Width contract needed by those specs: the `full-width-enabled` body
class and the main-outlet grid. It is loaded only in the normal integration
context; the missing-dependency context installs no fixture and adds no class.

The production component remains dependent on the official
[Full Width component](https://github.com/discourse/discourse-full-width-component).
