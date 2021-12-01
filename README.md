# Week 11 - Homework <br/> Model outputs and `purrr`

Welcome to your assignment for **week 11**. As usual, **Clone** this repo into your own :computer:  using RStudio, as we saw in class.

For this week's assignment you will need to create a short **"report" in an rmarkdown** format with its associated `.md` and `.html` outputs. 

## The data

For this week's assignment we are going to use a dataset of net primary production (NPP) of yhe giant kelp *Macrocystis pyrifera* estimated at three different sites for the period 2002 - 2019. The data is part of the Santa Barbara Coastal LTER which aims to investigate the importance of land and ocean processes in structuring giant kelp forest ecosystems. The original data can be foud [here](https://sbclter.msi.ucsb.edu/data/catalog/package/?package=knb-lter-sbc.112). I have modified the dataset from what it is provided there slightly to make it suit the learning objectives of this assignment.

## Your tasks

Your main task for this homework assignment is to study the temporal trends of the dry-weight NPP of the giant kelp in the three sites that were monitored. in particular, I would like you to:

1. Using the tools from the `purrr` package that we have seen in class, fit a linear regression of the dry-weight NPP vs year for each of the sampled sites
2. Generate a summary table of the model reults showing the site as well as the slope, intercept, R-squared and the p-value of the model fit
3. Format this summary table using the tools seen in class
4. Using the tools from the `purrr` package generate a `.pdf` figure for each site showing the data, the linear regression through the data, as well as the equation and R-squared of the regression

## wrap-up

Finally, once you have completed the exercises, as usual:

- Once you are done with the Rmd  files, save the changes, make sure files are properly saved in te **Rmarkdown** folder.
- Knit your document
- Commit all the changes to the *repo/R project* (remember to write a commit mesage!)
- **Push** all changes back to **GitHub**
- Go to GitHub and check that it all worked out


## A few hints

- Be careful with the indentation in your YAML header
- Make sure to save your `.rmd` file in the rmarkdown folder **before** you knit your file
- You will need to use the **{here}** package to correctly load the ditch data into the `.Rmd` file as well as to save the figures.

## Reminder
 
 - In the Exam you will be deducted points for not following proper file structure inside your repo/project, so make sure you start developing good practices now. This applies as well to coding style, so make sure to review the [Tidyverse style guide](https://style.tidyverse.org/)


As always, feel free to use [the Issues](https://github.com/UM-R-for-EnvSci-Registered-Student-2021/General_Discussion/issues) section of the of [General Discussion](https://github.com/UM-R-for-EnvSci-Registered-Student-2021/General_Discussion) repo to ask any questions you might have or to share anny issues you come across. 

Note for those of you **still waiting for a final Git/GitHub set up**. You can still use the green button labelled "code" to download a zip version of the repository. You can unzip this anywhere in your computer and open the R project by double clicking the blue cube .RProj file. then you will be able to work on the project, edit and save like you would on any other R project.The only difference, for now, is that you will not be able to "push" the changes back to github, as that folder is not being tracked by Git/GitHub. We will need to find a separate solution for you to get this folder back to me once you are done with the asignment (e.g. zip eail attachment or dropbox/google drive/onedrive link)

Can't wait to see what themes you come up with!

*Happy coding!*

Pepe

