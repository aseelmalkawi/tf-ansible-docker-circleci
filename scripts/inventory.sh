cat <<EOF > ../ansible/inventory
[private]
$1
[public]
$2
EOF
