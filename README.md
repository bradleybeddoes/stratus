# Stratus

**Authors**: [@smangelsdorf](http://github.com/smangelsdorf) and [@bradleybeddoes](http://github.com/bradleybeddoes)

Spin up multiple Linux nodes via VirtualBox and Kickstart for developers working from OSX.

Now with more mitchellh/vagrant goodness, supplying the Vagrant public key by default for root SSH access.

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
		
   Be sure to add the appropriate line to your ~/.bash_profile as shown in the installer output then reload it.
   
                $> rbenv install 2.0.0-p247
                $> rbenv global 2.0.0-p247      # optional you may like to set this locally with rbenv local instead 
		
3. Install [bundler](http://bundler.io/)

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
We've tested this using the CentOS 6.[4,5] minimal ISO. It will probably work for other distributions without much bother. Ubuntu is next on the list to officially support.

To build a CentOS 6.5 ISO:

    $> bash scripts/automate_iso

If CentOS 6.5 isn't to your liking the script offers a number of options:

    $> bash scripts/automate_iso -h
    
### Launch the provided kickstart server
When you're spinning up new machines it is important to have the kickstart server running in the background. This is just a very basic sinatra app running in unicorn that maps a machines MAC addresses to kickstart files.

	$> cd kickstartserver; 
	$> bundle exec unicorn; 

### Create a machine
Once you have your iso is built you only need a few details to get a new machine running. By default the Vagrant public key mitchellh/vagrant/tree/master/keys is authorized for login as root on the new machine. Add any additional public keys you'd like to authorize to keys/authorized_keys

    $> bash scripts/create_machine -n <machine name> -a <ip address>

    e.g.

    $> bash scripts/create_machine -n db1 -a 192.168.56.10
    … once vm is running …
    $> ssh root@192.168.56.10

This process publishes a file to `kickstartserver/files/<mac>.ks`. Once the file has been served to a machine to complete its kickstart process the file is renamed `kickstartserver/files/<mac>.ks.served` so you can clean these up at some future time.

Once the create machine process has completed it will appear in your Virtualbox management UI and you can manage it as normal. You want to use this to create a [Vagrant base box](http://docs.vagrantup.com/v2/virtualbox/boxes.html).

Once again the script offers a number of options:

    $> bash scripts/create_machine -h

The -x to automatically startup the new machine after provisioning and -g options are particularly useful.

#### Installing VirtualBox guest additions
If you're planning on shipping this as a Vagrant base box or just want to do things like shared directories you'll want to additionally install the Virtualbox guest additions:

1. Run `yum update kernel*`
1. Reboot the VM
1. Install required packages `yum install gcc kernel-devel kernel-headers dkms make bzip2 perl
` 
1. Set kernel source dir ``export KERN_DIR=/usr/src/kernels/`uname -r` ``
1. Grab the x86_64 RPM for the latest VirtualBox guest tools currently http://download.virtualbox.org/virtualbox/4.3.10/
1. Install the VirtualBox RPM `yum install <downloaded rpm>`



## Multiple Machines
If you'd like to spin up multiple machines undertake the following steps:

1. Create a `machines.csv` file from `machines.csv.dist`. Here is an example:

		app1,192.168.56.20,myorg/applications,false
		app2,192.168.56.21,myorg/applications,false
		app3,192.168.56.22,myorg/applications,false
		db1,192.168.56.23,myorg/cluster,false
		db2,192.168.56.24,myorg/cluster,false
	
2. Run the multiple machines script

		$> bash scripts/create_multiple_machines
	
For a really fun experience set all the execute flags to true :trollface:. This script could be quite easily extended for more advanced cases.

## Advanced Topics

### SSH config population
To enable auto population of your ~/.ssh/config file with name and IP of the machines you create do the following:

1. Checkout [ssh-config command line tools](https://github.com/wthys/ssh-config) and add to your path
2. In your setup file change update_ssh to be true
3. Build machines!