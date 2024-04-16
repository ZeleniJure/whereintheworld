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

Infiscal has some issues with:
- credentials. Even when using universal auth (or something like this) it loaded some kind of token successfully and then also successfully failed
- expects secret namespacing to be done in certain way, not apparent from the docs immediately

I am using my instance, managed by terraform. The part needed for this assignment was done by hand.

## Database
Postgres is installed in cluster, separated (enough) from the main application. I should have 

Database frontend is the _pgpool_, responsible for connection management to the actual postgres database(s) behind the scenes.

**TODO:**
 - add the `pg-db` to infiscal as well
 - configure volume backups

## Helm
Is ugly :/ I've hardcoded some values in the _values.yaml_, which should be outside. And I have not configured ingress yet.

## Random
Cities import doesn't work because of permissions issue: Permission denied: '/usr/local/lib/python3.9/site-packages/cities/data'

I suspect it would be solved with a magic config var, since there's also an option to download it on the fly...

## Roadmap

I'll add it after the meeting now
