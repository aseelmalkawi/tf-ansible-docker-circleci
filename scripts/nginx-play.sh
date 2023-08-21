cat <<EOF > ../ansible/nginxPlaybook.yml
- hosts: public
  become: true
  tasks:
    - name: install nginx
      apt: 
        name: nginx 
        state: present

    - name: update
      ansible.builtin.command: apt update

    - name: start nginx
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true  # Ensure Nginx starts on boot

    - name: Pause for a moment before restarting
      pause:
        seconds: 5
    
    - name: Run nginx script
      ansible.builtin.script:
        cmd: ../scripts/nginx.sh $1 $2
    
    - name: Run nginx script
      ansible.builtin.script:
        cmd: ../scripts/nginxconfig.sh
    
    - name: update
      ansible.builtin.command: apt update
EOF