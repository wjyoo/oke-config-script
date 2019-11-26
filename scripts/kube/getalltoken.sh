rm -rf alltokens.txt
touch alltokens.txt
for ((ui=201;ui<251;ui++));do
    cat /home/"user"$ui"/auth_token" >> alltokens.txt
done
