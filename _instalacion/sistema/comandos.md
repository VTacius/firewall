systemctl restart sssd.service

chmod 700 /etc/sssd/sssd.conf
systemctl restart sssd.service 

sed -E -i 's/^#\s*(account\s*required\s*pam_access.so)/\1/g' /etc/pam.d/sshd

grep -q '+ : root : 192.168.2.20/27' /etc/security/access.conf || sed '$a + : root : 192.168.2.20/27' /etc/security/access.conf  -i
grep -q '+ : MinsalAdminFirewall : ALL' /etc/security/access.conf || sed '$a + : MinsalAdminFirewall : ALL' /etc/security/access.conf  -i
grep -q -- '- : ALL: ALL' /etc/security/access.conf || sed '$a - : ALL: ALL' /etc/security/access.conf  -i

grep -q 'pam_mkhomedir.so' /etc/pam.d/common-session || sed -i '/"Additional" block/ a session\trequired\tpam_mkhomedir.so umask=0022 skel=/etc/skel' /etc/pam.d/common-session
grep -q 'pam_mkhomedir.so' /etc/pam.d/common-session-noninteractive || sed -i '/"Additional" block/ a session\trequired\tpam_mkhomedir.so umask=0022 skel=/etc/skel' /etc/pam.d/common-session-noninteractive

cat <<MAFI>/etc/sudoers.d/ruth 
%MinsalAdminFirewall ALL=(ALL) NOPASSWD:/bin/su
MAFI
