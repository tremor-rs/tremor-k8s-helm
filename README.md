# Tremor for Kubernetes

<img alt="Tremor for Kubernetes logo" src="tremornetes.png" width="25%" height="25%"/>


This project derives from work by the Kubernetes team at Wayfair of general
interest to users of Tremor and Kubernetes. The original work was by [Njegos Railic](https://github.com/njegosrailic) from Wayfair's Kubernetes SRE Team.

The project can be used as a template for creating standard tremor images
for Kubernetes. This project can be forked and modified for specific use
cases. 

Generally useful enhancements, improvements, fixes and changes that are encouraged.
If you have made a change you would like to contribute please submit a pull request!


## Getting started

This project assumes familiarity with Tremor, Kubernetes and Helm.

## Quick start on Mac OS X

### Install [docker for mac](https://docs.docker.com/docker-for-mac/)

We use docker for access to the tremor image and local Kubernetes support

```bash
$ brew cask install docker
```

### Install [helm](https://helm.sh/)

We use helm for package management and deployment lifecycle management

```bash
$ brew install helm
```

### Install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

We use kind for local Kubernetes deployment on development machines that are docker enabled.

```bash
$ brew install kind
```

### Optionally, install Visual Studio Code support

If you use the Visual Studio Code IDE - we recommend installing the official [Kubernetes Tools](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools) and [docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extensions

### Create a Kubernetes cluster

```bash
$ kind create cluster --name tremor
```

Verify cluster creation

```bash
$ kubectl cluster-info --context kind-tremor
```

The cluster name will be the name of the cluster created during `kind create cluster` with `kind-` prefixed.

### Package our helm chart for tremor

After making any required changes for your deployment of tremor we can create
a deployable package

```bash
$ helm package .
```

We may need to delete and recreate the package during development

```bash
$ helm install example tremor-kuberenetes-0.2.0.tgz
$ helm delete example
```

### Validate deployments

Check that our `daemonset` has deployed ok

```bash
$ kubectl get daemonsets
NAME                       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
example-tremor-kubernetes  1         1         1       1            1           <none>          78m
```

Check pod creation has worked ok

```bash
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
example-tremor-kubernetes-c8r8w  1/1     Running   0          80m
```

Inspect the log output for any other deployment errors:

```bash
$ kubectl logs example-tremor-kubernetes-c8r8w
+ [ -n  ]
+ [ -z ]
+ TREMOR_DIR=/etc/tremor

...

+ exec /usr/bin/tini /tremor -- server run --logger-config /etc/tremor/logger.yaml -f /etc/tremor/config/config.yaml /etc/tremor/config/main.trickle
tremor version: 0.11.4 HEAD:0c643f419124c0484a817202e0d7a79a33996dd3
tremor instance: tremor
rd_kafka version: 0x000000ff, 1.5.0
allocator: snmalloc
2021-05-25T10:09:53.304913733+00:00 INFO tremor_runtime::version - tremor version: 0.11.4 HEAD:0c643f419124c0484a817202e0d7a79a33996dd3
2021-05-25T10:09:53.304982855+00:00 INFO tremor_runtime::version - rd_kafka version: 0x000000ff, 1.5.0
2021-05-25T10:09:53.305173577+00:00 INFO tremor_runtime::onramp - Onramp manager started

...

2021-05-25T10:09:53.396942845+00:00 INFO tremor_runtime::pipeline - [Pipeline::tremor://localhost/pipeline/main/01] Connecting tremor://localhost/onramp/metronome/01/out to 'in'
2021-05-25T10:09:53.397082716+00:00 INFO tremor_runtime::system - Binding binding tremor://localhost/binding/default/01
2021-05-25T10:09:53.397618268+00:00 INFO tremor::server - Listening at: http://0.0.0.0:9898
Listening at: http://0.0.0.0:9898
{"onramp":"metronome","ingest_ns":1621937403376574270,"id":0}
{"onramp":"metronome","ingest_ns":1621937413376994143,"id":1}
{"onramp":"metronome","ingest_ns":1621937423377406517,"id":2}
{"onramp":"metronome","ingest_ns":1621937433357035918,"id":3}

...

{"onramp":"metronome","ingest_ns":1621942260121807140,"id":486}
{"onramp":"metronome","ingest_ns":1621942270121987716,"id":487}
{"onramp":"metronome","ingest_ns":1621942280122466690,"id":488}
{"onramp":"metronome","ingest_ns":1621942290101218178,"id":489}
{"onramp":"metronome","ingest_ns":1621942300101332444,"id":490}
```

If you can see metronome events with the default example then your deployment looks good!