wget --no-check-certificate https://cisofy.com/files/lynis-2.1.1.tar.gz
tar -xzvf lynis-2.1.1.tar.gz
cd lynis
chmod a+x lynis
./lynis audit system -Q

echo "Warnings:\n"  > lynis_log
cat /var/log/lynis-report.dat | grep warning | sed –e ‘s/warning\[\]\=//g’ >> lynis_log
echo "Suggestions:\n " >> lynis_log
cat /var/log/lynis-report.dat | grep suggestion | sed –e ‘s/suggestion\[\]\=//g’ >> lynis_log
echo "available_shells:\n" >> lynis_log
cat /var/log/lynis-report.dat | grep available_shell | sed –e ‘s/available_shell\[\]\=//g’ >> lynis_log

