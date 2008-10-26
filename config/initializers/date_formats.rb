ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
	:pretty => "%A, %B %d, %Y %l:%M %p",
	:date => '%m/%d/%Y',
	:date_small => "%A %m/%d",
	:date_time12  => "%m/%d/%Y %l:%M%p",
	:date_time24  => "%m/%d/%Y %H:%M"
)
