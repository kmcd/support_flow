Delayed::Worker.delay_jobs = false if Rails.env.test?
Delayed::Worker.delay_jobs = false if Rails.env.development?