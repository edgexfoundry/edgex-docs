# Documentation for developing with EdgeX-Docs
[![Build Status](https://jenkins.edgexfoundry.org/view/EdgeX%20Foundry%20Project/job/edgexfoundry/job/edgex-docs/job/main/badge/icon)](https://jenkins.edgexfoundry.org/view/EdgeX%20Foundry%20Project/job/edgexfoundry/job/edgex-docs/job/main/) [![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/edgexfoundry/edgex-docs)](https://github.com/edgexfoundry/edgex-docs/pulls) [![GitHub Contributors](https://img.shields.io/github/contributors/edgexfoundry/edgex-docs)](https://github.com/edgexfoundry/edgex-docs/contributors) [![GitHub Committers](https://img.shields.io/badge/team-committers-green)](https://github.com/orgs/edgexfoundry/teams/edgex-docs-committers/members) [![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/edgexfoundry/edgex-docs)](https://github.com/edgexfoundry/edgex-docs/commits)

## Local Development (docker) (recommended)

The most common use case for local development of edgex-docs will be to verify changes to the HTML. To facilitate docs verification you can run the following command:

```shell
make serve
```

Once running, you can view the rendered content locally and makes changes to your documentation and preview them in realtime with a browser at:  
http://localhost:8008

---

If you only want to verify the documentation will build successfully you can run the following command:

```shell
make build
```

---

When done, you can clean up with:

```shell
make clean
```

## Local Development (native)

In order to render and preview the site locally (without docker) you will need a few things to get started.

1) You will need to install python and pip
2) After python is installed, you'll need the following python dependencies:

* `pip install mkdocs`
* `pip install mkdocs-material==8.2.1`
* `pip install mkdocs-swagger-ui-tag`
* 'pip install mkdocs-macros-plugin'


3) Once you have all the pre-reqs installed. You can simply run `mkdocs serve` and view the rendered content locally and makes changes to your documentation and preview them in realtime with a browser at http://0.0.0.0:8001/edgex-docs.

## Checking for broken links when developing docs

To check that all the links in the documentation set are valid:

1. Install the htmlproofer plugin (native only):

	> Note: if using the docker method, this is already installed in the image

	```shell
	pip install mkdocs-htmlproofer-plugin
	```

2. Export the `ENABLED_HTMLPROOFER` environment variable.

	> Note: This adds about 5 minutes each time a change is made, so it is recommended to do once all changes are ready.

	```shell
	export ENABLED_HTMLPROOFER=true
	```

3. Run `make build` or `make serve`. Broken links will be listed at the end of the build process.

Warning: the check for invalid / broken links does take some time and will add significantly to the build and serve times.

## "Publishing" your changes

Publishing is done by the jenkins pipeline. Once a PR is merged, the changes will be reflected on the documentation site, hosted under [gh-pages] branch and served by Github Pages.

The different versions of the documentation are maintained in separate branches.
The `main` branch hosts the source files for the version that is under development as well as the following **production site files**:

- `docs/CNAME` - DNS record which tells Github Pages to serve the content at https://docs.edgexfoundry.org instead of https://edgexfoundry.github.io/edgex-docs
- `docs/index.html` - site index page that redirects from `/` to `/{latest-release}`
- `docs/versions.json` - version info to populate the site version drop-down menu

The pipeline copies the files to separate directories inside [gh-pages] branch. 
For example, when the dev version is 2.2:

| Source                  | Production             |
|-------------------------|------------------------|
| main/docs/CNAME         | gh-pages/CNAME         |
| main/docs/index.html    | gh-pages/index.html    |
| main/docs/versions.json | gh-pages/versions.json |
| main/docs_src/*         | gh-pages/2.2/*         |
| jakarta/docs_src/*      | gh-pages/2.1/*         |
| ireland/docs_src/*      | gh-pages/2.0/*         |

Other files such as for CI checks and guidelines are also copied from all branches.

## Versioning the docs

When a new version of EdgeX is released, we version the docs as well. There are four steps to make this happen:

1) Create a branch without production site files

    i) Create a branch from `main` for the released documentation
    The branch name should be the new EdgeX release name.
    For example, for 2.2, a `kamakura` branch is created.

    ii) Remove **production site files** from the branch, listed [here](#publishing-your-changes).
    This is necessary to avoid overriding production files; see [#680](https://github.com/edgexfoundry/edgex-docs/issues/680).

2) Add the version to be added to the `docs/versions.json` file. This file will populate the drop down in the site deployed at https://docs.edgexfoundry.org

``` json
[
    {"version": "1.1", "title": "1.1-Fuji", "aliases": []},
    {"version": "1.2", "title": "1.2-Geneva", "aliases": []}
    {"version": "[new version number here]", "title": "[name that is visible in the drop down]", "aliases": []}
]
```

3) The value placed in `version` property in the json above *MUST* match the name of the folder that contains the versioned content in the [gh-pages] branch. This is specified by updating the `site_dir:` property in the `mkdocs.yml` file:

``` yaml
site_name: EdgeX Foundry Documentation
docs_dir: ./docs_src
site_dir: ./docs/1.2 #UPDATE THE VERSION NUMBER HERE TO MATCH WHATS IN THE VERSION.JSON
site_description: 'Documentation for use of EdgeX Foundry'
site_author: 'Michael Johanson'
site_url: 'https://edgexfoundry.github.io/edgex-docs/'
repo_url: 'https://github.com/edgexfoundry/edgex-go'
repo_name: 'edgex/edgex-go'
copyright: 'Copyright &copy; 2020 EdgeX Foundry'
...
```

Once this is done and merged, the build job will place content in the specified folder in the gh-pages branch. 

4) Update the `docs/index.html` to redirect from `/` to the most recent release directory.
For example, if the latest release is `2.1`:

``` html
<!DOCTYPE html>
<html>
<head>
<title>Redirecting</title>
<script>
    window.location.replace("2.1"); //UPDATE ME
</script>
</head>
<body>
</body>
</html>
```

 [gh-pages]: https://github.com/edgexfoundry/edgex-docs/tree/gh-pages
