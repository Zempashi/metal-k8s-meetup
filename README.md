# metal-k8s-meetup
Scripts for kubernetes meetup in Paris featuring metal-k8s


## Installation
To get started with metal-k8s on AWS install [terraform|https://www.terraform.io/] and clone this repository:
```
$ git clone https://github.com/Zempashi/metal-k8s-meetup
$ cd metal-k8s-meetup
```

then optionnaly:
```
$ make config
```
to look at the configuration file (AWS profile, region, vpc, ...), but usually no need to adjust any settings.

To roll-out the deployment:
```
$ make
```

## Usage
At the end of the deployment, you will find a generated inventory in `./metal-k8s/inventories/cluster1/hosts.ini`

```
ip-172-16-85-205.eu-west-2.compute.internal ansible_host=35.176.73.233 ansible_user=centos ansible_become=True
ip-172-16-111-167.eu-west-2.compute.internal ansible_host=52.56.85.209 ansible_user=centos ansible_become=True
ip-172-16-80-231.eu-west-2.compute.internal ansible_host=35.177.115.85 ansible_user=centos ansible_become=True
ip-172-16-123-25.eu-west-2.compute.internal ansible_host=18.130.85.144 ansible_user=centos ansible_become=True
ip-172-16-49-185.eu-west-2.compute.internal ansible_host=35.177.218.143 ansible_user=centos ansible_become=True

[etcd]
ip-172-16-85-205.eu-west-2.compute.internal
ip-172-16-111-167.eu-west-2.compute.internal
ip-172-16-80-231.eu-west-2.compute.internal
ip-172-16-123-25.eu-west-2.compute.internal
ip-172-16-49-185.eu-west-2.compute.internal

[kube-master]
ip-172-16-85-205.eu-west-2.compute.internal
ip-172-16-111-167.eu-west-2.compute.internal
ip-172-16-80-231.eu-west-2.compute.internal

[kube-node]
ip-172-16-85-205.eu-west-2.compute.internal
ip-172-16-111-167.eu-west-2.compute.internal
ip-172-16-80-231.eu-west-2.compute.internal
ip-172-16-123-25.eu-west-2.compute.internal
ip-172-16-49-185.eu-west-2.compute.internal

[k8s-cluster:children]
kube-master
kube-node

[k8s-cluster:vars]
metal_k8s_lvm={'vgs': {'kubevg': {'drives': ['/dev/xvdf']}}}
```

To issue a kubectl command, you need to go on the first master. The internal IP here is `ip-172-16-85-205.eu-west-2.compute.internal`
and you'll see the external IP on top section (under ansible_host var): `35.176.73.233`

Then:
```
$ ssh centos@35.176.73.233
$ sudo su
# /usr/local/bin/kubectl get nodes
```

## Destroy
Simply
```
make AA="-e state=absent"
```

**note**: you can pass any argument to ansible via the AA (ANSIBLE_ARGS) var
