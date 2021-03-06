# StatTrak Night

A Sourcemod plugin for automating a beacon hunting event in CS:GO.

# Requirements

- CS:GO Server running SourceMod

# Download

Go to the [Releases](https://github.com/purplg/StatTrakNight/releases) section to download the latest `stattraknight.smx`.

# Installation

1. Start in the CS:GO server's root directory then navigate to `csgo/addons/sourcemod/plugins/`
2. Drop the `stattraknight.smx` file there.
3. Either run `sm plugins refresh` in the CS:GO console or restart the CS:GO server.

# Usage

> **Note:** Just like most SourceMod plugins, `sm_statrak` in console is the equivalent of `!stattrak` and `/stattrak` in chat. The only difference is that the `!` shows up in chat while the `/` does not.

| Command               | Action                                    |
|-----------------------|-------------------------------------------|
| sm_st                 | Shows the scoreboard                      |
| sm_st start [seconds]	| Start on next round or after # [seconds]	|
| sm_st stop [seconds]	| Stop on next round or after # [seconds]   |
| sm_st points          | Prints your points                        |
| sm_st optout          | Opt out of the game                       |
| sm_st optin           | Opt back into the game                    |

# License

This project is licensed under the MIT License

Full license can be viewed [here](LICENSE).
