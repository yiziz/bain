require 'csv'

namespace :seed do
  namespace :from_csv do
    desc 'import states csv data'
    task :states, [:file] => :environment do |t,args|
      csv_text = File.read(Rails.root.join(args[:file]))
      csv = CSV.parse(csv_text, :headers => false, :encoding => 'ISO-8859-1')
      header_to_column = csv.first.map.with_index do |name, i|
        [name.strip.downcase.to_sym, i]
      end.to_h
      data = csv.from(1)
      ActiveRecord::Base.transaction do
        data.each do |row|
          code = row[header_to_column[:code]]
          name = row[header_to_column[:name]]
          State.create!(code: code, name: name) unless State.exists?(code: code)
        end
      end
    end

    desc 'import providers csv data'
    task :providers, [:file] => :environment do |t,args|
      # load all states from db into hash
      state_code_to_id = State.all.map do |state|
        [state.code, state.id]
      end.to_h

      csv_text = File.read(Rails.root.join(args[:file]))
      csv = CSV.parse(csv_text, :headers => false, :encoding => 'ISO-8859-1')
      header_to_column = csv.first.map.with_index do |name, i|
        [name.strip.downcase.gsub(' ', '_').to_sym, i]
      end.to_h
      data = csv.from(1)
      ActiveRecord::Base.transaction do
        # roll all back on failure
        data.each do |row|
          attrs = {}
          header_to_column.each do |k,v|
            key = k
            value = row[v]
            k_s = k.to_s
            if k_s.start_with?('total')
              value = value.to_i
            elsif k_s.start_with?('average')
              key = "#{k_s}_in_cents".to_sym
              value = value.gsub(/[$,.]/, '').to_i
            elsif k_s.end_with?('provider_id')
              key = :external_provider_id
            elsif k_s.end_with?('state')
              key = :state_id
              value = state_code_to_id[value]
            end
            attrs[key] = value
          end
          Provider.create!(**attrs)
        end
      end
    end
  end
end
