# Documentation for developing with EdgeX-Docs
[![Build Status](https://jenkins.edgexfoundry.org/view/EdgeX%20Foundry%20Project/job/edgexfoundry/job/edgex-docs/job/master/badge/icon)](https://jenkins.edgexfoundry.org/view/EdgeX%20Foundry%20Project/job/edgexfoundry/job/edgex-docs/job/master/) [![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/edgexfoundry/edgex-docs)](https://github.com/edgexfoundry/edgex-docs/pulls) [![GitHub Contributors](https://img.shields.io/github/contributors/edgexfoundry/edgex-docs)](https://github.com/edgexfoundry/edgex-docs/contributors) [![GitHub Committers](https://img.shields.io/badge/team-committers-green)](https://github.com/orgs/edgexfoundry/teams/edgex-docs-committers/members) [![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/edgexfoundry/edgex-docs)](https://github.com/edgexfoundry/edgex-docs/commits)


## Local Development (docker) (recommended):

`docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material`

## Local Development (native)

In order to render and preview the site locally (without docker) you will need a few things to get started. 
1) You will need to install python (Python 3) and pip (pip3)
2) After python is installed, you'll need the following python dependencies:
`pip install mkdocs-material`
3) Once you have all the pre-reqs installed. You can simply run `mkdocs serve` and view the rendered content locally and makes changes to your documentation and preview them in realtime with a browser open. 

Installing of mkdocs-material will also cause other Python packages to be installed to include `mkdocs` and `mkdocs-material-extensions`.

## "Publishing" your changes

Publishing is now done by the jenkins pipeline. Once a PR is merged to master, the changes will be reflected on the documentation site. 
 
## Versioning the docs

When a new version of EdgeX is released, we version the docs as well. There are three steps to make this happen:

1) Add the version to be added to the `versions.json` file. This file will populate the drop down in the site deployed at https://docs.edgexfoundry.org 
``` json
[
    {"version": "1.1", "title": "1.1-Fuji", "aliases": []},
    {"version": "1.2", "title": "1.2-Geneva", "aliases": []}
    {"version": "[new version number here]", "title": "[name that is visible in the drop down]", "aliases": []}
]
```

2) The value placed in `version` property in the json above *MUST* match the name of the folder that contains the versioned content in the `gh-pages` branch. This is specified by updating the `site_dir:` property in the `mkdocs.yml` file:
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

3) The last step, once everything is in place, is to update the site. The docs site is a statically hosted site on github pages from the `gh-pages` branch. Normally we leave this branch alone as the build job will take care of updating it. However, versioning is a bit different.You'll need to do TWO things.  Ideally this would be automated, but it is manual for now given it happens once per release.
    1. You'll need to repeat step 1 against the `gh-pages` branch. Think of it as master is dev and `gh-pages` is prod.
    2. You'll need to update the `index.html` to redirect users to the current version: 

``` html
<!DOCTYPE html>
<html>
<head>
<title>Redirecting</title>
<script>
    window.location.replace("1.2"); //UPDATE ME
</script>
</head>
<body>
</body>
</html>
```


 