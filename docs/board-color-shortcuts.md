# Board color shortcuts

Mouse shortcuts for coloring board squares and drawing arrows, comparing
**scidCommunity** with Lichess, chess.com and ChessBase.

- **scidCommunity** is listed first.
- `—` means the shortcut is not assigned in that program.
- Values in parentheses `( )` are inferred from program behavior and were not
  directly confirmed in the original chart.
- `Cyan / blue` indicates the original chart was ambiguous between the two.

## Right-click

| Shortcut                         | scidCommunity   | Lichess | chess.com   | ChessBase |
| -------------------------------- | --------------- | ------- | ----------- | --------- |
| Right-click                      | Green           | Green   | Orange      | —         |
| Alt + right-click                | Blue            | Blue    | Cyan / blue | Blue      |
| Ctrl + right-click               | Red             | Red     | Red         | —         |
| Shift + right-click              | Yellow          | —       | Green       | —         |
| Ctrl + Alt + right-click         | Orange          | Orange  | Cyan / blue | Orange    |
| Shift + Alt + right-click        | Cyan            | —       | —           | Cyan      |
| Ctrl + Shift + right-click       | — (unassigned)  | (Red)   | (Red)       | —         |
| Ctrl + Shift + Alt + right-click | — (unassigned)  | (Orange) | (Cyan)      | (Cyan)    |

## Left-click

| Shortcut                        | scidCommunity | Lichess | chess.com | ChessBase |
| ------------------------------- | ------------- | ------- | --------- | --------- |
| Alt + left-click                | Green         | —       | —         | Green     |
| Ctrl + Alt + left-click         | Yellow        | —       | —         | Yellow    |
| Shift + Alt + left-click        | Red           | —       | —         | —         |

## Notes

- **scidCommunity**, unmodified right-click uses the color selected in the marker
  palette, which is green by default.
- **scidCommunity** intentionally leaves `Ctrl + Shift + right-click` and
  `Ctrl + Shift + Alt + right-click` unassigned. Tk would otherwise fall back to
  a less specific binding (producing yellow and orange respectively), so both
  combinations are explicitly bound to a no-op.
- The **scidCommunity** left-click shortcuts are ChessBase-style additions.
  ChessBase assigns red to `Shift + Ctrl + Alt + left-click`; **scidCommunity**
  uses `Shift + Alt + left-click` instead.
