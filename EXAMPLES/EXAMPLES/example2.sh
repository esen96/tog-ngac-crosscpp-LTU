# Authors: André Christofferson & Wilma Krutrök

# Here we load all the policies that will be used in following test example
# We would like to use setpol?policy=all here but it does not work as intended.

echo 'Load policies'
curl -s -G "http://127.0.0.1:8001/paapi/loadpol" --data-urlencode "policyfile=EXAMPLES/EXAMPLES/book_lift.pl" --data-urlencode "token=admin_token"
curl -s -G "http://127.0.0.1:8001/paapi/loadpol" --data-urlencode "policyfile=EXAMPLES/EXAMPLES/book_room.pl" --data-urlencode "token=admin_token"
curl -s -G "http://127.0.0.1:8001/paapi/loadpol" --data-urlencode "policyfile=EXAMPLES/EXAMPLES/read_file.pl" --data-urlencode "token=admin_token"

echo ''
echo 'Load conditions'
curl -s -G "http://127.0.0.1:8001/paapi/loadcondi" --data-urlencode "cond_elements=[
	condition_predicate(is_same_location,[name, name]),
	(is_same_location(LocationA,LocationB) :- LocationA == LocationB)
	]" --data-urlencode "token=admin_token"
# Does not work to write "is_same_location(Location, Location)." here.

curl -s -G "http://127.0.0.1:8001/paapi/loadcondi" --data-urlencode "cond_elements=[
	condition_predicate(is_business_hours,[]),
	(is_business_hours :- condition_variable_value(hour_now,Hour), Hour =< 20, Hour >= 7)
	]" --data-urlencode "token=admin_token"
# Raises 'Internal server error: compound_name_arity/3: Type error: `compound' expected, found `is_business_hours' (an atom)' but works. 


echo ''
echo 'Set the policy to book_lift '
curl -s -G "http://127.0.0.1:8001/paapi/setpol?policy=all" --data-urlencode "token=admin_token"

echo ''
echo 'Set Access query - G G G G D D D D'
# Allowed to book and condition fulfilled
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o1&ar=book&cond=is_same_location(locationA,locationA)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o2&ar=book&cond=is_same_location(locationB,locationB)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u3&object=o1&ar=book&cond=is_same_location(locationA,locationA)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u3&object=o2&ar=book&cond=is_same_location(locationA,locationA)"

# Allowed to book but condition not fulfilled
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o1&ar=book&cond=is_same_location(locationA,locationB)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o2&ar=book&cond=is_same_location(locationB,locationA)"

# Not allowed to book
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o2&ar=book&cond=is_same_location(locationA,locationA)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o1&ar=book&cond=is_same_location(locationA,locationA)"

# echo ''
# echo 'Set the policy to book_room'
# curl -s -G "http://127.0.0.1:8001/paapi/setpol?policy=book_room" --data-urlencode "token=admin_token"

echo ''
echo 'Set Access query - G G G G D D D D'
# Allowed to book and condition fulfilled
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o1&ar=book&cond=is_same_location(locationA,locationA)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o2&ar=book&cond=is_same_location(locationB,locationB)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u3&object=o1&ar=book&cond=is_same_location(locationA,locationA)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u3&object=o2&ar=book&cond=is_same_location(locationA,locationA)"

# Allowed to book but condition not fulfilled
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o1&ar=book&cond=is_same_location(locationA,locationB)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o2&ar=book&cond=is_same_location(locationB,locationA)"

# Not allowed to book
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o2&ar=book&cond=is_same_location(locationA,locationA)"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o1&ar=book&cond=is_same_location(locationA,locationA)"

# echo ''
# echo 'Set the policy to read_file'
# curl -s -G "http://127.0.0.1:8001/paapi/setpol?policy=read_file" --data-urlencode "token=admin_token"

echo ''
echo 'Set Access query - G G G G D D (if localhost time is between 07-18, else all Denies)'
# Allowed to read and condition fulfilled 
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o1&ar=read"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o2&ar=read"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u3&object=o1&ar=read"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u3&object=o2&ar=read"

# Not allowed to read
curl -s "http://127.0.0.1:8001/pqapi/access?user=u1&object=o2&ar=read"
curl -s "http://127.0.0.1:8001/pqapi/access?user=u2&object=o1&ar=read"
