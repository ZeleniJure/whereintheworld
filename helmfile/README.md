# Basic infra
I didn't integrate this into a CI, but did it manually:
```bash
docker build . -t registry.skube.si/witw:1.0.3 && docker push registry.skube.si/witw:1.0.3
```
The rest of the code just assumes that this image exists!

OCI image repository is hosted by me...

## Deploying
Using [helmfile](https://helmfile.readthedocs.io/en/latest/) for deploy, because I haven't tried it yet ¯\_(ツ)_/¯ 

How to? Just run [./helmfile.sh](helmfile.sh), which will run helmfile in docker with some default mounts, and apply the definition in the [helmfile.yaml](./helmfile.yaml).

It works pretty nice for simple things like this I suppose. It's fast and easy for "local development". Perhaps worthwhile before 

## Secrets
Secrets are managed by infiscal with the exception of infiscal and docker registry credentials. The latter for no good reason. These were added by hand to the k8s cluster.
The infiscal bootstrap problem with the password can be solved in 2-ish ways:
- use something similar to [sealed secrets](https://github.com/bitnami-labs/sealed-secrets)
- not worry too much and restrict access to the namespace in kubernetes + smack over an alert where ever metrics are being shipped to
- rotating such a base secret can be problematic :/
- there's usually a sleek way for "native" integration into where you run your managed kube cluster, or you do such things using a management cluster

Infiscal has some issues with:
- credentials. Even when using universal auth (or something like this) it loaded some kind of token successfully and then also successfully failed
- expects secret namespacing to be done in certain way, not apparent from the docs immediately
- it just syncs secrets, they are not encrypted in kubernetes. It's just a UI over secrets... Unless I missed something, but encrypting them shouldn't be a configuration option, this should just work out of the box.

I am using my instance, managed by terraform. The part needed for this assignment was done by hand.

## Database
Postgres is installed in cluster, separated (enough) from the main application. I should have 

Database frontend is the _pgpool_, responsible for connection management to the actual postgres database(s) behind the scenes.

**TODO:**
 - add the `pg-db` to infiscal as well
 - configure volume backups

## Helm
Is ugly :/ I've hardcoded some values in the _values.yaml_, which should be outside. And I have not configured ingress yet.

I would not:
- put database installation into the helm
- having infiscal support in the helm doesn't hurt, but honestly, it's not needed. Most apps assume secrets are handled outside
- metics collection and autoscaling (keda?) should also be handled outside the helm

I would:
- tweak config maps to better support application configuration
- add readme with some examples
- clean it up, I would not consider current state of the chart "production ready"
- set rolling restarts as the default on the deployment

## Random
Cities import doesn't work because of permissions issue: Permission denied: '/usr/local/lib/python3.9/site-packages/cities/data'

I suspect it would be solved with a magic config var, since there's also an option to download it on the fly...

## Roadmap

- get rid of all TODOs, and implement changes discussed in chapters above
- the entire observability is missing (there's sentry, but not configured). For app and k8s!
- (nginx/envoy can be configured with dynamic load balancing -> Peak EWMA )
- with observability in place use keda for autoscaling, taking cpu/mem/request queue in account perhaps
- set up CDN with tweaked whitenoise. Or it won't help much, since we are deploying the app each minute.
- this is internal app, so we can serve content on one route, and have a different internal-only-ingress for things like `/admin` route. Or move all 'internal' routes to `/internal/xyz` and have this as a general rule for everything. This is cool since most "outside attacks" will try /, /login, /admin, and if we move these we can avoid a DDOS or two
- use a different route for readines and liveliness checks. Current one is not optimal, and does not take into account possible initialization of other services in the app. Similar to /internal, these could be standardized across apps in the org as well
- have a CI/DI pipeline! Run some tests, scan resulting image for basic CVE's, check for secrets in code, lint, ...
- maybe it's time to squash some migrations. Or have a base sql dump, import it, then run (squashed) migrations. Having a pipeline for such things can be nice for django apps...
- set up basic canary with gateway API / whatever service mesh we have / argo rollouts
- set up certbot and external-dns automation
- vacation
