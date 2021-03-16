function cleanup {
#!/bin/bash
echo "destroying demo nim"
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    terraform destroy --auto-approve
else
    echo "canceling"
fi
}
