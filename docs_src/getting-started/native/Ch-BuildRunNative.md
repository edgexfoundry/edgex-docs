# Native Build and Run

There are instances, in both development as well as production, where you need to run EdgeX "natively."  That is, you want to run EdgeX on the native operating system / hardware outside of any emulation, container platform, Docker, Docker Compose, Snaps, etc..  Per [PC Magazine](https://www.pcmag.com/encyclopedia/term/run-native), running natively 

> "is to execute software written for the computer's natural, basic mode of operation; for example, a program written for Windows running under Windows. Contrast with running a program under some type of emulation or simulation".
>

The following guides will assist you in building and running EdgeX natively.

!!! Alert
    Please note that the rest of the EdgeX documentation, outside of these native build and run guides, focuses on running EdgeX in Docker containers or EdgeX snaps.  Using containers or snaps are usually the easiest and preferred way to run EdgeX - especially when you are not a developer and not familiar with operating system commands, compiling code, building program artifacts, and running programs in an operating system.  
    
    Therefore, these native build and run guides do not contain every aspect or option for running EdgeX in native environments.  They are meant as a quick start for more seasoned developers or administrators comfortable with running a system by setting up build tools/environments, pulling source code, building from source and running the program outputs (executable artifacts) of the build without the benefits and ease that container platforms and similar technology bring.

!!! Warning
    These build and run guides offer some assistance to seasoned developers or administrators to help build and run EdgeX in environments **not always supported by the project**.  EdgeX was built to be platform independent.  As such, we believe most of EdgeX can run on almost any environment (on any hardware architecture and almost any operating system).  However, there are elements of the EdgeX platform that will not run on all operating systems.  For example, Redis will not run on Windows OS natively and some device services are only capable of running on Linux distributions or ARM64 platforms.
    
    Existence of these guides **does not imply current or future support**.  Use of these guides should be used with care and with an understanding that they are the community's best effort to provide advanced developers with the means to begin their own custom EdgeX development.

## Guides

- [Build and Run on Linux x86/x64](./Ch-BuildRunOnLinuxDistro.md)
- Build and Run on Linux ARM64 - *coming soon*
- Build and Run on Linux ARM32 - *coming soon*
- Build and Run on Windows - *coming soon*