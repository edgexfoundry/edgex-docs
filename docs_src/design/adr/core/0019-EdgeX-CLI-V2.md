# EdgeX-CLI V2 Design
 

## Status

**Approved** (by TSC vote on 10/6/21)

## Context
This ADR presents a technical plan for creation of a 2.0 version of edgex-cli which supports the new V2 REST APIs developed as part of the Ireland release of EdgeX.

## Existing Behavior
The latest version of edgex-cli  (1.0.1) only supports the V1 REST APIs and thus cannot be used with V2 releases of EdgeX.

As the edgex-cli was developed organically over time, the current implementation has a number of bugs mostly involving a lack of consistent behavior, especially with respect to formatting of output.

Other issues with the existing client include:

- lack of tab completion
- default output of commands is too verbose
- verbose output sometime prevents use of jq 
- static configuration file required (i.e. no registry support)
- project hierarchy not conforming to best practice guidelines 

## History
The original Hanoi V1 client was created by a team at VMWare which is no longer participating in the project. 
Canonical will lead the development of the Ireland/Jakarta V2 client.

## Decision

1. Use standardized command-line args/flags

| Argument/Flag      | Description |
| ----------- | ----------- |
| `-d`, `--debug`      | show additional output for debugging purposes (e.g. REST URL, request JSON, …). This command-line arg will replace -v, --verbose and will no longer trigger output of the response JSON (see -j, --json).       |
| `-j`, `--json`   | output the raw JSON response returned by the EdgeX REST API and *nothing* else. This output mode is used for script-based usage of the client.    |
| `--version`   | output the version of the client and if available, the version of EdgeX installed on the system (using the version of the metadata data service)   |


2. Restructure the Go code hierarchy to follow the [most recent recommended guidelines](https://github.com/golang-standards/project-layout). For instance /cmd should just contain the main application for the project, not an implementation for each command - that should be in /internal/cmd

3. Take full advantage of the features of the underlying command-line library, [Cobra](https://github.com/spf13/cobra), such as tab-completion of commands.

4. Allow overlap of command names across services by supporting an argument to specify the service to use: `-m/--metadata`, `-c/--command`, `-n/--notification`, `-s/--scheduler` or `--data` (which is the default). Examples:

    - `edgex-cli ping --data`
    - `edgex-cli ping -m`
    - `edgex-cli version -c`

5. Implement all required V2 endpoints for core services

    **Core Command**
    - **`edgex-cli command`** `read | write | list`

    **Core Data**
    - **`edgex-cli event`** `add | count | list | rm | scrub**`
    - **`edgex-cli reading`** `count | list`

    **Metadata**
    - **`edgex-cli device`**  `add | adminstate | list | operstate | rm | update`
    - **`edgex-cli deviceprofile`**  `add | list | rm | update`
    - **`edgex-cli deviceservice`** ` add | list | rm | update`
    - **`edgex-cli provisionwatcher`**  `add | list | rm | update`
    
    **Support Notifications**
    - **`edgex-cli notification`** `add | list | rm`
    - **`edgex-cli subscription`** `add | list | rm`

   **Support Scheduler**
    - **`edgex-cli interval`** `add | list | rm | update`

    **Common endpoints in all services**
    - **`edgex-cli version`**
    - **`edgex-cli ping`**
    - **`edgex-cli metrics`**
    - **`edgex-cli status`**

    The commands will support arguments as appropriate. For instance:
    - `event list` using `/event/all` to return all events
    - `event list --device {name}` using `/event/device/name/{name}` to return the events sourced from the specified device.


6.  Currently, some commands default to always displaying GUIDs in objects when they're not really needed. Change this so that by default GUIDs aren't displayed, but add a flag which causes them to be displayed.

7. **scrub** may not work with Redis being secured by default. That might also apply to the top-level `db` command (used to wipe the entire db). If so, then the commands will be disabled in secure mode, but permitted in non-secure mode.

8. Have built-in defaults with port numbers for all core services and allow overrides, avoiding the need for static configuration file or configuration provider.

9. *(Stretch)* implement a `-o`/`--output` argument which could be used to customize the pretty-printed objects (i.e. non-JSON).


10. *(Stretch)* Implement support for use of the client via the API Gateway, including being able to connect to a remote EdgeX instance. This might require updates in go-mod-core-contracts.



## References

- [Command Line Interface Guidelines](https://clig.dev/)
- [The Unix Programming Environment, Brian W. Kernighan and Rob Pike](https://en.wikipedia.org/wiki/The_Unix_Programming_Environment)
- [POSIX Utility Conventions](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html)
- [Program Behavior for All Programs, GNU Coding Standards](https://www.gnu.org/prep/standards/html_node/Program-Behavior.html)
- [12 Factor CLI Apps, Jeff Dickey](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46)
- [CLI Style Guide, Heroku](https://devcenter.heroku.com/articles/cli-style-guide)
- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)