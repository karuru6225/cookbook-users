#
# Cookbook Name:: bash
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

data_ids = node['users'] && node['users']['id'] || data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)
  user u['id'] do
    home u['home']
    password u['password']
    action [:create]
    supports manage_home: true
    not_if "grep '^#{id}:' /etc/passwd"
  end
  if u['expired']
    user u['id'] do
      action :lock
    end
  end
  directory u['home'] + '/.ssh' do
    owner u['id']
    group u['id']
    mode '0700'
    action [:create]
  end
  template u['home'] + '/.ssh/authorized_keys' do
    owner u['id']
    group u['id']
    mode '0600'
    source 'authorized_keys.erb'
    variables(
      pubkey: u['ssh-keys']
    )
    action [:create]
  end
  if u['sudoer']
    template '/etc/sudoers.d/' + u['id'] do
      owner 'root'
      group 'root'
      mode '0440'
      source 'sudoers.erb'
      variables(
        uname: u['id'],
        nopasswd: u['sudoer']['nopasswd'] || false,
        permit_commands: u['sudoer']['permit_commands'] || ['ALL']
      )
    end
  end
end
