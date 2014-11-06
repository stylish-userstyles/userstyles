-- daily reports - anything in the last 24 hours
UPDATE styles SET daily_reports = 0;
UPDATE styles s
  JOIN (
    SELECT style_id, COUNT(*) c FROM daily_report_counts WHERE report_date >= DATE_SUB(NOW(), INTERVAL 1 DAY) GROUP BY style_id
  ) d
  ON s.id = d.style_id
  SET s.daily_reports = d.c;

-- move anything before yesterday to the historical count table
INSERT IGNORE INTO report_counts
  (style_id, report_date, reports)
  (SELECT style_id, DATE(report_date), COUNT(*) FROM daily_report_counts WHERE report_date < DATE_SUB(CURDATE(), INTERVAL 1 DAY) GROUP BY style_id, DATE(report_date));
DELETE FROM daily_report_counts WHERE report_date < DATE_SUB(CURDATE(), INTERVAL 1 DAY);
