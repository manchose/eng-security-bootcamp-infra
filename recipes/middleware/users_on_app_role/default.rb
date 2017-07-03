host = node[:host]
team_no = node[:team_no]

if attrs[:users][host]
  p attrs[:users][host]
  attrs[:users][host].each do |username|
    user_info = node[:users][username]

    # Create group
    unless (primary_gid = user_info[:gid])
      primary_gid = user_info[:uid]
      group user_info[:name] do
        gid primary_gid
      end
    end

    # Create user
    user user_info[:name] do
      uid   user_info[:uid]
      gid   primary_gid
      shell user_info[:shell]
      home  user_info[:home_directory]
      create_home user_info[:create_home]
    end

    # Set user's full name
    if user_info[:full_name]
      execute "usermod -c '#{user_info[:full_name]}' #{user_info[:name]}"
    end

    # Deploy ~/.ssh/authorized_keys
    if user_info[:home]
      if user_info[:home]['.ssh'] && user_info[:home]['.ssh'][:authorized_keys]
        dot_ssh_dir = File.join(user_info[:home_directory], '.ssh')
        directory dot_ssh_dir do
          owner user_info[:uid].to_s
          group primary_gid.to_s
          mode '0700'
        end

        file File.join(dot_ssh_dir, 'authorized_keys')  do
          owner user_info[:uid].to_s
          group primary_gid.to_s
          mode '0600'
          content user_info[:home]['.ssh'][:authorized_keys].join("\n")
        end
      end
    end
  end
end
