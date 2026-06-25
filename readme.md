# A list of burner email providers

Throw away email addresses (burner emails) are great for single use signups where you would like the content but rather not give up your email.

I'm okay with people using burner email addresses to get my free content, I just need to be able to filter them out of my list so it doesn't drive up bounces and hurt deliverability. 

Please send a PR with any new ones you find. 

## Merging upstream domains

This repo is a fork of [wesbos/burner-email-providers](https://github.com/wesbos/burner-email-providers). It has diverged significantly from upstream and syncing the full fork should be done with care.

To merge in domains from [ivolo/disposable-email-domains](https://github.com/ivolo/disposable-email-domains), run the script at [`merge-spam-domains/merge.rb`](merge-spam-domains/merge.rb). It downloads the remote list, merges it with the current `emails.txt`, deduplicates, sorts, verifies, and writes the result back.

```
ruby merge-spam-domains/merge.rb
```

## APIs

### Free

* [Disposable](https://github.com/0x19/disposable)
* [Disposable Email Detector](https://www.disposable-email-detector.com)
* [Firefox Relay](https://github.com/mozilla/fx-private-relay)
* [Verifier](https://verifier.meetchopra.com/)


## Services

### Free tier

* [Firefox Relay](https://relay.firefox.com/)



## Libraries

### Elixir

* [Burnex](https://github.com/Betree/burnex)

### Go

* [go-burner-email-providers](https://github.com/lindell/go-burner-email-providers)

### NodeJs

* [burner-email-providers](https://github.com/findie/burner-email-providers)

### PHP

#### Symfony

* [secit-pl/validation-bundle](https://github.com/secit-pl/validation-bundle#burneremail)

### Scala

* [Burner4s](https://github.com/ariskk/burner4s)

## Host your own

* [Docker](https://hub.docker.com/r/emailhippo/dea-id-community-api-wesbos-v1)
