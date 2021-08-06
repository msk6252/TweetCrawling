# TweetCrawlingWordPressPost

## lamdba Build

```
rm -rf vendor
docker run -v `pwd`:/var/task -it lambci/lambda:build-ruby2.7 bundle install --path vendor/bundle
sls deploy
```
