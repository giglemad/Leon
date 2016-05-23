require 'smarter_csv'

lines = SmarterCSV.process('clean_columns_output.csv')


#csv_keys = "date_inscription,title,last_name,first_name,age_birthdate,phone,adresse_rue_et_numero,zipcode,city,country,zipcode_proposed_housing,address_of_housing_if_different_from_address,lent_area,lent_area_description,occupants_usual_number,animal_presence_description,languages_spoken,possible_stay_length,willing_to_host_families_with_children,nearby_facilities,is_owner,professional_situation,willing_to_teach_its_job,interests,about_me,hosting_motivation,first_heard_of_calm_from,first_heard_of_singa_from,other_informations_i_want_to_share,has_participated_in_a_calm_meeting,email,username,number_of_people_i_can_host,possible_stay_could_begin_starting_at_approximation,willing_to_pay_for_hosted_people_transportation_to_home,walking_time_from_public_transportation,willing_to_talk_to_journalists_about_hosting_experience,lent_sleeping_area_description,departement,follow_up".split(',')

bad_calm_inputs = []
lines.each_with_index do |line,index|

  ActiveRecord::Base.transaction do
    person = Person.new(inscription_type: 'hosting_family')

    person.assign_attributes({
      google_form_sign_up_date: line[:date_inscription],
      title: line[:title],
      last_name: line[:last_name],
      first_name: line[:first_name],
      age_approximation: line[:age_birthdate],
      phone: line[:phone],
      languages_approximation: line[:languages_spoken],
      interests_approximation: line[:interests],
      about_me: line[:about_me],
      address_lines: line[:adresse_rue_et_numero],
      zipcode: line[:zipcode],
      city: line[:city],
      country: line[:country],
      first_heard_of_calm_from: line[:first_heard_of_calm_from],
      first_heard_of_singa_from: line[:first_heard_of_singa_from],
      email: line[:email]
    })

    hosting_family_info_attributes = {
      possible_stay_length: line[:possible_stay_length],
      willing_to_talk_to_journalists_about_hosting_experience: line[:willing_to_talk_to_journalists_about_hosting_experience],
      willing_to_pay_for_hosted_people_transportation_to_home: line[:willing_to_pay_for_hosted_people_transportation_to_home],
      willing_to_host_families_with_children: line[:willing_to_host_families_with_children],
      willing_to_teach_its_job: line[:willing_to_teach_its_job],
      possible_stay_could_begin_starting_at: line[:possible_stay_could_begin_starting_at_approximation],
      number_of_people_i_can_host: line[:number_of_people_i_can_host],
      other_informations_i_want_to_share: line[:other_informations_i_want_to_share],
      hosting_motivation: line[:hosting_motivation],
      professional_situation: line[:professional_situation],
      follow_up: line[:follow_up]
    }

    hosting_family_info_attributes[:has_participated_in_a_calm_meeting] =
      if line[:has_participated_in_a_calm_meeting].to_s.downcase == "oui"
        true
      elsif (line[:has_participated_in_a_calm_meeting].nil? || line[:has_participated_in_a_calm_meeting].to_s.downcase == "non")
        false
      else
        bad_calm_inputs << [index,line[:has_participated_in_a_calm_meeting]]
        #raise "bad value has_participated_in_a_calm_meeting was #{line[:has_participated_in_a_calm_meeting]} instead of Oui or Non"
      end

    if line[:address_of_housing_if_different_from_address] == 'Je ne suis pas concerné(e)'
      hosting_family_info_attributes.merge!({
        address_lines: line[:adresse_rue_et_numero],
        zipcode: line[:zipcode],
        city: line[:city]
      })
    else
      hosting_family_info_attributes.merge!({
        zipcode: line[:zipcode_proposed_housing],
        address_lines: line[:address_of_housing_if_different_from_address]
      })
    end

    hosting_family_info_animal_presence =
      (line[:animal_presence_description] == 'Aucun') ? false : true

    hosting_family_info_animal_presence_description =
      hosting_family_info_animal_presence ? line[:animal_presence_description] : nil

    hosting_family_info_attributes.merge!({
      lent_area: line[:lent_area],
      lent_area_description: line[:lent_area_description],
      lent_sleeping_area_description: line[:lent_sleeping_area_description],
      occupants_usual_number: line[:occupants_usual_number],
      animal_presence: hosting_family_info_animal_presence,
      animal_presence_description: hosting_family_info_animal_presence_description,
      is_owner: line[:is_owner]
    })


    hosting_family_info_nearby = {
      nursery: (line[:nearby_facilities] =~ /Crèche/) ? true : false,
      primary_school: ( line[:nearby_facilities] =~ /Ecole primaire/) ? true : false,
      secondary_school: ( line[:nearby_facilities] =~ /Collège/ ) ? true : false,
      high_school: ( line[:nearby_facilities] =~ /Lycée/) ? true : false,
      university: ( line[:nearby_facilities] =~ /Université/ ) ? true : false,
      professional_formation_center: ( line[:nearby_facilities] =~ /Centre de formation professionnelle/) ? true : false,
      french_learning_possibilities: ( line[:nearby_facilities] =~ /Possibilité de cours de français/ ) ? true : false
    }

    %w( nursery primary_school secondary_school high_school university professional_formation_center french_learning_possibilities).each do |facility|
      hosting_family_info_attributes.merge!({
        ('has_nearby_' + facility).to_sym => hosting_family_info_nearby[facility.to_sym]
      })
    end

    begin
      person.save!
      person.reload.hosting_family_info_attributes = hosting_family_info_attributes
      person.save!
    rescue Exception => e
      puts e
      binding.pry
    end
    puts person.reload.id
  end
end

puts bad_calm_inputs
bad_calm_inputs
