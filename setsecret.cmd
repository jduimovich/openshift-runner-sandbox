
@echo off
oc whoami --show-token >openshift.login.token
set /P LOGINQ=< openshift.login.token
del openshift.login.token
Set LOGIN=%LOGINQ:"=%

oc whoami --show-server >openshift.server
set /P SERVERQ=< openshift.server
del openshift.server
Set SERVER=%SERVERQ:"=%
echo  The server is /%SERVER%/
echo  The token is  /%LOGIN%/
 
gh secret set OPENSHIFT_SERVER -b %SERVER%
gh secret set OPENSHIFT_TOKEN -b %LOGIN%

IF "%MY_GITHUB_TOKEN%"=="" (GOTO :missing_gh_token) ELSE (echo Setting Github Token)
gh secret set REPO_TOKEN -b %MY_GITHUB_TOKEN%
goto :end

:missing_gh_token
echo missing github token in env var "MY_GITHUB_TOKEN" needed to install a runner

:end