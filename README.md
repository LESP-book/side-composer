# Side Composer

Side Composer is a Discourse Theme Component that docks the composer to the
right on wide screens, while leaving Discourse core and the page layout owned by
Discourse and Full Width.

## Installation

1. Install and activate the official
   [Full Width component](https://github.com/discourse/discourse-full-width-component).
2. Install and activate Side Composer as a child component of the same theme.
3. Open a composer at an `xl`-wide viewport (80rem or wider) and use the
   sidebar-mode button in the composer controls.

Side Composer does not provide a replacement for Full Width. Without Full
Width, the feature remains unavailable; staff see a dependency notice and
regular users do not. Do not enable this component together with the Horizon
theme, which already includes the same composer peek behavior.

Supported behavior includes desktop wide-screen topic, reply, edit, private
message, and new-topic composers; sidebar shown/hidden states; preview;
fullscreen; the current composer redesign; and iPad keyboard-related core
classes. Mobile/narrow-screen side docking, draggable side widths, and custom
breakpoint settings are intentionally not supported. Third-party themes that
rewrite `#main-outlet-wrapper` may not be compatible. The side is currently
fixed to the right, including in RTL.

## Source and synchronization

The component skeleton follows the official
[`discourse/composer-peek`](https://github.com/discourse/composer-peek)
component at `1f8283ba07c1aedb5cbf38e8c1dd59ea406970f8`. Its behavior and layout
were synchronized from Horizon in Discourse at
`f7c85e6089cac8318e76bb0c58e8e3e898152a0f`; the Full Width dependency was
reviewed at `c371e57a02db6956d5a253402ce1b824bb24a8a1`.

| source | commit | last reviewed |
| --- | --- | --- |
| `discourse/composer-peek` skeleton | `1f8283b` | 2026-09-16 |
| Discourse Horizon behavior | `f7c85e6` | 2026-09-16 |
| `discourse-full-width-component` contract | `c371e57` | 2026-09-16 |

The implementation deliberately keeps the `peekModeActive` preference and
`peek-mode-active` body-class protocol used by Discourse core and chat.
