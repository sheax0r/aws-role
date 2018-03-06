# Aws::Role

CLI to allow easy aws role assumption.

## Why assuming roles with the AWS CLI sucks.

Assuming roles in AWS via the CLI is clunky with the default tooling. You need to do something like this:

```
# Assume the role. Man that's a long string to have to paste on the CLI!
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/xaccounts3access --role-session-name s3-access-example

# Now copy the secret key, access key, and token from the output and paste it:
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_KEY=...
export AWS_SESSION_TOKEN=...

# Okay, NOW you can do stuff using the role....
```

## How to make it better.

Before doing this, you need to have the following environment variables exported:

  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`
  * `AWS_MFA_SERIAL` -- you only need this if you require MFA for role assumption (which hopefully, you do).
  * `AWS_DEFAULT_REGION`

I suggest putting these into a `~/.secrets` file so you don't type this stuff out all the time.

Once this is done, you can do the following:

1. Create a ~/.aws_roles file. It's yaml, and it looks like this:

```yaml
my_role: arn:aws:iam::123456789012:role/xaccounts3access
my_other_role: arn:aws:iam::2109876312412:otherrole/admin
```

2. Assume the role:
```bash
# You'll get prompted for your MFA token if necessary:
eval `aws-role -r my_role`

# Now do the things!
aws s3 ls # etc
```

3. Oh you want to login to the UI or print out a link? No problem!
```bash
# Uses "open" under the hood, only works on OSX:
aws-role -r my_role --ui

# Just print out the url instead of opening it:
aws-role -r my_role --url
```

## Installation

```bash
gem install aws-role
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sheax0r/aws-role.
