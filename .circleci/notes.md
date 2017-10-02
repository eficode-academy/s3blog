
## Swap to s3 bucket hosting
I need you to create a CNAME for www.praqma.com to the s3 bucket.  This should be in the DNS file:
 `www 10800 IN CNAME www.praqma.no.s3-website.eu-central-1.amazonaws.com.`

## Add challenge tokens to letsencrypt
Just need to prove that we control the domain.

## Add certs to cloud front

Upload the certs in IAM Certificate manager in the AWS console.]

## Move CNAME DNS to point to cloud front

This should be in the DNS file:
 `www 10800 IN CNAME d1ale400jojy13.cloudfront.net.`

## Outstanding work

* Invalidate Cloudfront cache on deploy
* Delete bucket contents script
* Terraform automation
* Terraform state in s3
* Find where to store secrets
* Find a permanent certificate solution, either with automation of letsencrypt updates or buying a longer lived cert.
* Script to empty bucket (needed to delete a s3 bucket for terraform)
* Slack integration

https://stackoverflow.com/questions/25883888/why-amazon-s3-bucket-name-must-be-the-same-as-website-name-when-hosting-a-static

Old DNS CNAME
praqma.github.io

# Creating the certificate
brew install certbot

# Based on notes here
https://www.codeword.xyz/2016/01/06/lets-encrypt-a-static-site-on-amazon-s3/

sudo certbot certonly --manual --server https://acme-v01.api.letsencrypt.org/directory -d www.praqma.no -d www.praqma.com

# Output
~/tmp/praqma/praqma.com   1020-Make-new-tokens-for-letsencrypt-on-www.praqma.no  sudo certbot certonly --manual --server https://acme-v01.api.letsencrypt.org/directory  -d www.praqma.no
Password:
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for www.praqma.no

-------------------------------------------------------------------------------
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
-------------------------------------------------------------------------------
(Y)es/(N)o: y

-------------------------------------------------------------------------------
Create a file containing just this data:

I31oZvegnk10AlCyGt5RYMf3ONTUvUlcnq_xpm5cWEI.wdSL3roJgAep9axz_KLXyJd80mYjo62dAZ1_6Yzvg7Q

And make it available on your web server at this URL:

http://www.praqma.no/.well-known/acme-challenge/I31oZvegnk10AlCyGt5RYMf3ONTUvUlcnq_xpm5cWEI

-------------------------------------------------------------------------------
Press Enter to Continue
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/www.praqma.no/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/www.praqma.no/privkey.pem
   Your cert will expire on 2017-11-30. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

# Upload certificates

sudo aws iam upload-server-certificate \
     --server-certificate-name cert_www_praqma_com \
     --certificate-body file:///etc/letsencrypt/live/www.praqma.no/cert.pem \
     --private-key file:///etc/letsencrypt/live/www.praqma.no/privkey.pem \
     --certificate-chain file:///etc/letsencrypt/live/www.praqma.no/chain.pem \
     --path /cloudfront/certs/

## Output

    {
        "ServerCertificateMetadata": {
            "ServerCertificateId": "ASCAIH5HCINGQTK2P7GNS",
            "ServerCertificateName": "cert_www_praqma_com",
            "Expiration": "2017-11-30T07:45:00Z",
            "Path": "/cloudfront/certs/",
            "Arn": "arn:aws:iam::245112739366:server-certificate/cloudfront/certs/cert_www_praqma_com",
            "UploadDate": "2017-09-01T10:28:20.701Z"
        }
    }

## Notes on adding certs in AWS

The certs must be added in the us-east-1 region.

## Next
