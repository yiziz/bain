module Queries
  class ProviderQuery
    attr_reader :errors

    def initialize(scope=Provider.all)
      @scope = scope
      @errors = []
    end

    def filter(params={})
      scoped = filter_by_discharges(@scope, params[:min_discharges], params[:max_discharges])
      scoped = filter_by_average_covered_charges(scoped, params[:min_average_covered_charges], params[:max_average_covered_charges])
      scoped = filter_by_average_medicare_payments(scoped, params[:min_average_medicare_payments], params[:max_average_medicare_payments])
      scoped = filter_by_state(scoped, params[:state])
      scoped
    end

    def filter_by_discharges(scoped, min=nil, max=nil)
      if min.present?
        if string_is_valid_number?(min)
          min_float = min.to_f
          scoped = scoped.where('total_discharges >= ?', min_float)
        else
          @errors.push('min_discharges is invalid')
        end
      end

      if max.present?
        if string_is_valid_number?(max)
          max_float = max.to_f
          scoped = scoped.where('total_discharges <= ?', max_float)
        else
          @errors.push('max_discharges is invalid')
        end
      end

      scoped
    end

    def filter_by_average_covered_charges(scoped, min=nil, max=nil)
      if min.present?
        if string_is_valid_number?(min)
          min_float = min.to_f * 100
          scoped = scoped.where('average_covered_charges_in_cents >= ?', min_float)
        else
          @errors.push('min_average_covered_charges is invalid')
        end
      end

      if max.present?
        if string_is_valid_number?(max)
          max_float = max.to_f * 100
          scoped = scoped.where('average_covered_charges_in_cents <= ?', max_float)
        else
          @errors.push('max_average_covered_charges is invalid')
        end
      end

      scoped
    end

    def filter_by_average_medicare_payments(scoped, min=nil, max=nil)
      if min.present?
        if string_is_valid_number?(min)
          min_float = min.to_f * 100
          scoped = scoped.where('average_medicare_payments_in_cents >= ?', min_float)
        else
          @errors.push('min_average_medicare_payments is invalid')
        end
      end

      if max.present?
        if string_is_valid_number?(max)
          max_float = max.to_f * 100
          scoped = scoped.where('average_medicare_payments_in_cents <= ?', max_float)
        else
          @errors.push('max_average_medicare_payments is invalid')
        end
      end

      scoped
    end

    def filter_by_state(scoped, state_code=nil)
      return scoped if state_code.nil?

      state_id = State.state_code_to_id_hash[state_code.upcase]

      if state_id.nil?
        @errors.push('state is invalid')
        return scoped
      end

      scoped.where(state_id: state_id)
    end

    def string_is_valid_number?(s)
      # remove ,
      s = sanitize_number_string(s)
      last_decimal_index = s.rindex('.')

      # add necessary padding
      s = "0#{s}" if last_decimal_index == 0
      s = "#{s}.0" if last_decimal_index.nil?

      s.to_f.to_s == s
    end

    def sanitize_number_string(s)
      s.gsub(',', '').tr('0', '')
    end
  end
end
