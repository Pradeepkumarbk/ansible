#!/usr/bin/python
from passlib.hash import sha512_crypt
import getpass
import re
import sys


print("***** Chose your password wisely. It should be longer than 7 character, contain atleast a capital letter, a small letter and a number *****")
print( "Please enter your password")
raw_password = getpass.getpass()
print("Please repeat the password")
raw_password_repeat = getpass.getpass()
if raw_password != raw_password_repeat:
    print("Passwords doesn't match")
    sys.exit(1)

if len(raw_password) > 5:
    digit = re.match(".*\d.*", raw_password)
    small_l = re.match(".*[a-z].*", raw_password)
    cap_l = re.match(".*[A-Z].*", raw_password)
    if digit and small_l and cap_l:
        print("Good password. ")
    else:
        print("Come on, You can do better than that!")
        sys.exit(2)
else:
    print("Password length is less than 10 characters is not accepted.")
    sys.exit(3)
hash_password = sha512_crypt.using(rounds=5000).hash(raw_password)
print("Please note your password hash: \n%s" %hash_password)
