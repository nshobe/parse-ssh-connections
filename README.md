# parse-ssh-connections
Reads /etc/passwd to map users to home dirs and find out what ssh trusts exist.

*Note:* This _must_ be run as root. Hopefully this is obvious to you, but you can't read files in $home/.ssh unless you're root. If you can, please fix, that's bad.

## Design Intents
This is a nice simple tool to get your existing known ssh connections from all your users. I created this because I needed to create a map of what needed to be automated for existing deployments. It's also something you can ship out to your security dept for auditing.

## Options
Pretty straight forward:
 - "-v" Verbose: (not currently in use) for those that like interaction/logging
 - "-H" Header: Print headers on the CSV
 - "-o" Output Dir: Select where to dump the generated files, default is "/tmp" (safe on most systems)

A useful way to implement the -o is to write to an autofs volume (usually "/net/$hostname" if enabled) so you can gather all your output files in one location for concatination. I've written the output specifically for this intended use.
