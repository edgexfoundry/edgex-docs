# Sources for docs.edgexfoundry.org

## Setup 

In order to render and preview the site you will need a few things to get started. 
1) You will need to install python and pip
2) After python is installed, you'll need the following python dependencies:
`pip install mkdocs`
`pip install mkdocs-material`
3) You're ready to go!

## Local Development

Once you have all the pre-reqs installed. You can simply run `mkdocs serve` and view the rendered content locally and makes changes to your documentation and preview them in realtime with a browser open. By default typically the site is hosted at http://127.0.0.1:8080

running in docker coming soon...

## "Publishing" your changes

Until publishing of the docs is done by Jenkins, this will be a manual process. You'll just need to run
`mkdocs build`
This will re-generate the site and overwrite what is in the docs folder. Once this is merged into master, the changes will be available immediately on github pages.


