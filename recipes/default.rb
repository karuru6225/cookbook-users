#
# Cookbook Name:: bash
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

data_ids = data_bag('users')
data_ids.each do |id|
	u = data_bag_item('users', id)
	user u['id'] do
		home u['home']
		action [:create]
		supports :manage_home => true
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
		variables({
			:pubkey => u['ssh-keys']
		})
		action [:create]
	end
end
