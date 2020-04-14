# Documentation for developing with EdgeX-Docs

## Local Development (docker) (recommended):

`docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material:5.1.0`

## Local Development (native)

In order to render and preview the site locally (without docker) you will need a few things to get started. 
1) You will need to install python and pip
2) After python is installed, you'll need the following python dependencies:
`pip install mkdocs`
`pip install mkdocs-material==5.1.0`
3) Once you have all the pre-reqs installed. You can simply run `mkdocs serve` and view the rendered content locally and makes changes to your documentation and preview them in realtime with a browser open. 



## "Publishing" your changes

Publishing is now done by the jenkins pipeline. Once a PR is merged to master, the changes will be reflected on the documentation site. 
 