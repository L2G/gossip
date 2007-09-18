Gossip is a library that can be used to broadcast messages to multiple destinations, currently email, jabber, twitter, campfire, and the command line. 

The watchdog program watches a program execute and "barks" to destinations when it finishes.

Any program that uses the program can be configured with a site-wide configuration file, a per-user configuration file, or the command line. See watchdog.rb --help for a list of things to tweak.


To install:

prompt> rake install            # Run with administrator privileges

- or - 

prompt> ruby setup.rb config
prompt> ruby setup.rb setup
prompt> ruby setup.rb install    # Run with administrator privileges.


After installation, you can change site defaults by editing
lib/gossip/site-defaults.rb.