echo "Starting at `date`" >> ../log/update_report_counts.log
~/cron/db < ./update_report_counts.sql >> ../log/update_report_counts.log 2>&1
echo "Done at `date`" >> ../log/update_report_counts.log
