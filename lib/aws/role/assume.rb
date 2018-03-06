require "aws-sdk-core"
require "clamp"
require "yaml"

module AwsRole
  class Assume < Clamp::Command

    option %w{--access-key}, "AWS_ACCESS_KEY_ID", "aws access key id", required: true, environment_variable: "AWS_ACCESS_KEY_ID", attribute_name: :aws_access_key_id
    option %w{--secret-key}, "AWS_SECRET_ACCESS_KEY", "aws secret key", required: true, environment_variable: "AWS_SECRET_ACCESS_KEY", attribute_name: :aws_secret_access_key
    option %w{--region}, "REGION", "aws region", required: true, environment_variable: "AWS_DEFAULT_REGION", attribute_name: :aws_region
    option %w{-r --role}, "ROLE", "the role to assume", required: true, attribute_name: :role
    option %w{-d --duration}, "DURATION", "duration of the assumed credentials in seconds", default: 3600
    option %w{-s --serial}, "AWS_MFA_SERIAL", "MFA serial number", required: false, environment_variable: "AWS_MFA_SERIAL", attribute_name: :mfa_serial
    option %w{-f --file}, "ROLES_FILE", "Yaml file containing the list of roles", environment_variable: "AWS_ROLES_FILE", attribute_name: :roles_file, default: "#{ENV["HOME"]}/.aws_roles"
    option "--ui", :flag, "Set this if you want to switch roles in the UI"
    option "--url", :flag, "Set this if you want to print out the URL to be used to assume a role"

    parameter "PARAMETERS ...", "command to execute", required: false, attribute_name: :params

    def execute
      if ui? || url?
        match = role_arn.match(role_expression)
        account = match["account"]
        role_name = match["role_name"]
        url = "https://signin.aws.amazon.com/switchrole?account=#{account}&roleName=#{role_name}&displayName=#{role}"

        puts url if url?
        system("open '#{url}'") if ui?
      else
        creds = credentials
        if params.size > 0
          ENV['AWS_ACCESS_KEY_ID'] = creds.access_key_id
          ENV['AWS_SECRET_ACCESS_KEY'] = creds.secret_access_key
          ENV['AWS_SESSION_TOKEN'] = creds.session_token
          exec(params.join(" "))
        else
          %w{AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN}.each do |key|
            STDOUT.puts "unset #{key};"
          end
          STDOUT.puts "export AWS_ACCESS_KEY_ID=#{creds.access_key_id};"
          STDOUT.puts "export AWS_SECRET_ACCESS_KEY=#{creds.secret_access_key};"
          STDOUT.puts "export AWS_SESSION_TOKEN=$'#{creds.session_token}';"
        end
      end
    end

    private

    def sts
      @sts ||= ::Aws::STS::Client.new(aws_params)
    end

    def credentials
      sts.assume_role(assume_role_params).credentials
    end

    def assume_role_params
      result = {
        role_arn: role_arn,
        role_session_name: "srtools-cli",
        duration_seconds: Integer(duration)
      }
      if mfa_serial
        result [:serial_number] = mfa_serial
        result[:token_code] = mfa_token
      end
      result
    end

    def aws_params
      {
        region: aws_region,
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key,
      }
    end

    def mfa_token
      STDERR.puts "Enter your MFA code: "
      STDIN.gets.strip
    end

    def role_arn
      roles[role]
    end

    def roles
      @roles ||= YAML.load(File.read(roles_file))
    end

    def role_expression
      /arn:aws:iam::(?<account>\d.*):role\/(?<role_name>.*)/
    end
  end
end
