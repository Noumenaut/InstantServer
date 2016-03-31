![flavour](https://i.ytimg.com/vi/IFUsxk9I9mQ/hqdefault.jpg)

# Host system dependencies
You'll need virtualbox, vagrant, and git. Choco can be omitted, but I recommend it. 
Execute these commands from an administrative command shell: 

1. To install the 'Chocolatey Packages' windows package manager ``@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin``
1. To install VirtualBox ``choco install virtualbox``
1. To install Vagrant ``choco install vagrant``
1. To install Git ``choco install git``

# Instructions
1. ``(on the host)`` create a directory InstantServer-installers and place the Einstein installers in it.
1. ``(on the host)`` Download 'quicktimeinstaller.exe' from the Apple website and place it in the InstantServer-Installers directory
1. ``(on the host)`` ``git clone https://[your-git-username]@bitbucket.org/esq/instantserver.git``
1. ``(on the host)`` ``cd InstantServer``
1. ``(windows host)`` Use ``Server-Create.bat`` to build and launch a server. 
1. Wait for the desktop to display. In the Virtualbox window, press R-CTRL and DELETE. Log in with username 'vagrant' and password 'vagrant'
1. ``(windows host)`` Use ``Server-Delete.bat`` to tear down and dispose of the server. If you use the delete script on an image while it is still building, you might see unexpected results. 
1. ``(non-windows)`` Use ``./Server-Create`` to build and launch a server
1. ``(non-windows)`` Use ``./Server-Delete`` to tear down and dispose of the server. If you use the delete script on an image while it is still building, you might see unexpected results.

# Note about the Einstein Setup scripts: 
The automated installer scripts are still a work in progress, and you might find duplicate broken things in this directory while I set things in order. If you are using this and run across an issue, please feel free to follow up with me and I'll help. 

1. ``(on the guest vm)`` When the guest system finishes loading, launch ``c:\scripts\setup_einstein_[version].bat`` as Administrator
1. ``(on the guest vm)`` Complete the manual steps within the installers when they pop up (this will improve with time)

# Note about MINGW32
1. MINGW32/git-bash.exe will be helpful if you have linux guest images on a windows host.
1. Navigate to C:\Program Files\Git\ and launch git-bash.exe. Pin it to your taskbar.
1. The gnu core utilities in this binary come with an ssh client, which the Windows OS natively lacks. If you issue the ``vagrant ssh`` command from within a MINGW32 terminal session, you are logged into the running system without the requirement of setting up putty and ssh key pairs.