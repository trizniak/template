
# 3. Configure git with Rstudio ##############################################
# SOURCE : https://gist.github.com/Z3tt/3dab3535007acf108391649766409421

## set your user name and email :
usethis::use_git_config(user.name="YourName",
                        user.email="your@mail.com")

## set personal access token :
credentials::set_github_pat("YourPAT")
