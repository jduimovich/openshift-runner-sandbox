# openshiftrunner

This demo repo shows how to use our openshift runner installer to automate running workflows on OpenShift.

This repo containers two workflows.

The first workflow will check if an openshift runner is installed into your cluster and if not install it. Repeated runs will validate it's still runnning and if not, restart it. 
After installation of a runner, and validation it's active, a repository_dispatch is used to signal other workflows


```yaml
name: Install Runner and Dispatch Workflows
on: [ push, workflow_dispatch ] 
jobs:
  install-runner:
    runs-on: ubuntu-20.04
    name: Ensure Runner Installed, then signal workflows
    steps:  
      - uses: redhat-actions/oc-login@v1.1
        with:
          openshift_server_url: ${{ secrets.OPENSHIFT_SERVER }}
          openshift_token: ${{ secrets.OPENSHIFT_TOKEN }}
          namespace: jduimovich-code
          insecure_skip_tls_verify: true 
      - name: Ensure self hosted runner is running 
        uses: redhat-actions/self-hosted-runner-installer@main
        with:
          github_pat: ${{ secrets.REPO_TOKEN }}
          runner_labels: openshift
  run-post-runner-ready-workflows:
    runs-on: ubuntu-20.04
    needs: install-runner 
    steps:  
      - name: Signal dependent workflows waiting for runner-ready
        uses: jduimovich/repository-dispatch@main
        id: dispatch
        with:
          github-token: ${{ secrets.REPO_TOKEN }}  
          event-to-dispatch: runner-ready  
      - name: Result from the dispatch
        run: echo "Result ${{ steps.dispatch.outputs.result }}"

```

The dispatched workflows can be done as follows

```yaml
name: Simple Shell on openshift runner
env:    
  DEPLOY: "Shell simple workflow"
on:
  repository_dispatch:
    types: [runner-ready]
jobs:
  test-shell:
    name: Run an ls to show files LOCAL
    runs-on: [ self-hosted, openshift ]
    steps:
    - uses: actions/checkout@v2   
    - name: Shell test 
      run: |  
        ls -al 
```
