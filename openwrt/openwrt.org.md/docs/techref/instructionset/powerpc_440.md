# powerpc\_440

**As of 2017-01-10, [this target is not supported any more.](https://git.lede-project.org/?p=source.git%3Ba%3Dcommit%3Bh%3D06c76e41d7a0c936f5e4b6f43f331860e3b99d70 "https://git.lede-project.org/?p=source.git;a=commit;h=06c76e41d7a0c936f5e4b6f43f331860e3b99d70")**

The PPC440 is a 32-bit implementation of the Book E architecture meaning there are 32 bits in each internal register and that there are 32 address bits available for memory references. However, the MMU produces 36-bit physical addresses of which 2^32 can be referenced by a program using a particular MMU entry.

The PowerPC architecture specifies that two levels of privilege for program execution: user-mode and supervisor-mode. In user-mode, access to most registers including system control registers is denied. It is intended that most application programs be executed in user-mode so that they are protected from errant register changes made by other user-mode programs.

Book E provides for binary compatibility for 32-bit PowerPC application programs. Thus, existing application code, which uses only the instructions defined by the User Instruction Set Architecture book of the classic PowerPC architecture, will execute without modification on PowerPC Book E implementations. Book E specifies that binary instruction compatibility not necessarily be provided for privileged (supervisor- mode) PowerPC instructions.

[source](http://alacron.com/clientuploads/PDFs/forweb/440_Programming_Model.pdf "http://alacron.com/clientuploads/PDFs/forweb/440_Programming_Model.pdf")

## Download Packages

HTTP N/A FTP N/A

See [Mirrors](/downloads#mirrors "downloads") for more download sites.

## Devices with this instructionset
