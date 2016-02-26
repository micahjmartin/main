# main/tauth

tauth is a text based verification program for SSH servers. tauth sends a SMS message or Email message with a 5 digit pin that a user must enter in order to can access to a server. Users numbers and emails must be pre-entered into the program. Emails can only be sent with a GMAIL account configured for remote mail sending. Might error if users attempt to get email without.

To install:

curl https://raw.githubusercontent.com/micahjmartin/main/master/tauth/tauth-install.sh > tauth-install;
chmod +x tauth-install;
./tauth-install;

Enter email and email password

create SSH users and allow them in sshd_config

TAUTH add user

for each user to have tauth enabled
