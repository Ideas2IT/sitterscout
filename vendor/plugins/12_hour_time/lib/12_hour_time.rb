class ActiveRecord::Base
  def extract_callstack_for_multiparameter_attributes_with_ampm(pairs)
    attributes = extract_callstack_for_multiparameter_attributes_without_ampm(pairs)
    attributes.each do |name, values|
      klass = (self.class.reflect_on_aggregation(name) ||
                column_for_attribute(name)).klass
      if klass == Time && values.length == 6
        if values[5] == ActionView::Helpers::DateHelper::AM && values[3] == 12
          values[3] = 0
        elsif values[5] == ActionView::Helpers::DateHelper::PM && values[3] != 12
          values[3] += 12
        end
      end
    end
  end

  alias_method_chain :extract_callstack_for_multiparameter_attributes, :ampm
end

module ActionView::Helpers::DateHelper
  AM = 0
  PM = 1

  def select_hour_with_ampm(datetime, options = {}) 
    options[:twelve_hour] or return select_hour_without_ampm(datetime, options)

    hour = _12_hour(datetime)

    if options[:use_hidden]
      return hidden_html(options[:field_name] || 'hour', hour, options)
    end

    hour_options = []
    1.upto(12) do |val|
      selected = (hour == val) ? ' selected="selected"' : ''
      hour_options << %(<option value="#{leading_zero_on_single_digits(val)}"#{selected}>#{leading_zero_on_single_digits(val)}</option>\n)
    end

    select_html(options[:field_name] || 'hour', hour_options, options)
  end

  alias_method_chain :select_hour, :ampm


  def select_ampm(datetime, options = {})
    val = ''
    if datetime 
      val = (datetime.kind_of?(Fixnum) ? datetime : datetime.hour) < 12 ? AM : PM
    end

    if options[:use_hidden]
      return hidden_html(options[:field_name] || 'ampm', val, options)
    end

    ampm_options = []
    label = { AM => 'AM', PM => 'PM' }
    [AM, PM].each do |meridiem|
      selected = (meridiem == val) ? ' selected="selected"' : ''
      ampm_options << %(<option value="#{meridiem}"#{selected}>#{label[meridiem]}</option>\n)
    end

    select_html(options[:field_name] || 'ampm', ampm_options, options)
  end

  def select_time_with_ampm(datetime = Time.now, options = {})
    select = select_time_without_ampm(datetime, options)
    select << select_ampm(datetime, options) if options[:twelve_hour]
    select
  end

  alias_method_chain :select_time, :ampm

  private
    
    def _12_hour(datetime)
      return '' if datetime.blank?

      hour = datetime.kind_of?(Fixnum) ? datetime : datetime.hour
      hour = 12 if hour == 0
      hour -= 12 if hour > 12

      return hour
    end
end

class ActionView::Helpers::InstanceTag
  def date_or_time_select_with_ampm(options)
    options[:twelve_hour] and not options[:discard_hour] or
      return date_or_time_select_without_ampm(options)

    defaults = { :discard_type => true }
    options = defaults.merge(options)

    datetime = value(object)
    datetime ||= Time.now unless options[:include_blank]

    date_or_time_select_without_ampm(options) +
      select_ampm(datetime, options_with_prefix(6, options.merge(:use_hidden => options[:discard_hour])))
  end

  alias_method_chain :date_or_time_select, :ampm
end
