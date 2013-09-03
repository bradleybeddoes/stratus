# Stratus

**Authors**: [@smangelsdorf](http://github.com/smangelsdorf) and [@bradleybeddoes](http://github.com/bradleybeddoes)

Spin up multiple Linux nodes via VirtualBox and Kickstart for developers working from OSX.

You might find things to be broken as we're still hacking on this, patches welcome!.

Just like you'd pair good :wine_glass: with tasty :meat_on_bone: we recommend you pair this with [Ansible](http://www.ansibleworks.com) for extra developer :smiley:.

If you find this useful you're of course welcome to buy us :beers: and :pizza:.

## Getting started
### Virtualbox
1. Install the latest release of Virtualbox
2. Setup a Host-only Network called vboxnet0 using the IP range 192.168.56.0/24.
We find most development nodes are better suited to using static IP so tend to set the DHCP range from 192.168.56.201 to 192.168.56.254 with a server address of 192.168.56.200 (even this is probably excessive)

### Setup your machine
1. Install [homebrew](http://brew.sh)

2. Install the cdrtools formula

    	$> brew install cdrtools
    
3. Install [rbenv](https://github.com/sstephenson/rbenv)

		$> brew install rbenv
		$> brew install ruby-build
		
4. Install [bundler](http://bundler.io/)

		$> gem install bundler


4. Clone stratus to your machine

    	$> git clone git@github.com:bradleybeddoes/stratus.git
    	$> cd stratus

5. Setup stratus with basic directives for your machine.

    	$> cp setup.dist setup
   Edit this file to suit your local way of working. Each option is commented inline.
   
6. Setup environment for kickstart server

		$> cd kickstartserver && bundle install && cd ..

### Build an iso that will launch kickstart automatically
We've tested this using the CentOS 6.4 minimal ISO. It will probably work for other distributions without much bother. Ubuntu is next on the list to officially support.

To build a CentOS 6.4 ISO:

    $> bash scripts/automate_iso

If CentOS 6.4 isn't to your liking the script offers a number of options:

    $> bash scripts/automate_iso -h
    
### Launch the provided kickstart server
When you're spinning up new machines it is important to have the kickstart server running in the background. This is just a very basic sinatra app running in unicorn that maps a machines MAC addresses to kickstart files.

	$> cd kickstartserver; 
	$> bundle exec unicorn; 

### Create a machine
Once you have your iso is built you only need a few details to get a new machine running. By default your ~/.ssh/id_rsa.pub key is authorized for login as root on the new machine.

    $> bash scripts/create_machine -n <machine name> -a <ip address>

    e.g.

    $> bash scripts/create_machine -n db1 -a 192.168.56.10
    … once vm is running …
    $> ssh root@192.168.56.10

This process publishes a file to `kickstartserver/files/<mac>.ks`. Once the file has been served to a machine to complete its kickstart process the file is renamed `kickstartserver/files/<mac>.ks.served` so you can clean these up at some future time.

Once the create machine process has completed it will appear in your Virtualbox management UI and you can manage it as normal.

Once again the script offers a number of options:

    $> bash scripts/create_machine -h

The -x to automatically startup the new machine after provisioning and -g options are particularly useful.

## Putting it all together
Once you're ready to spin up multiple machines undertake the following steps:

1. Create a `machines.csv` file from `machines.csv.dist`. Here is an example:

		app1,192.168.56.20,myorg/applications,false
		app2,192.168.56.21,myorg/applications,false
		app3,192.168.56.22,myorg/applications,false
		db1,192.168.56.23,myorg/cluster,false
		db2,192.168.56.24,myorg/cluster,false
	
2. Run the multiple machines script

		$> bash scripts/create_multiple_machines
	
This will spin up multiple machines in parallel. For a really fun experience set all the execute flags to true :trollface:. This script could be quite easily extended for more advanced cases.

## Tasks
- [ ] Have machines auto configured in a specified zone for the DNS server running on the host
- [ ] Have ~/.ssh/config populated for new machines


