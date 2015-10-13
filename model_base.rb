class ModelBase < ModelBase

  def save
    attr_hash = self.attr_hash

    if attr_hash['id'].nil?
      QuestionsDatabase.instance.execute(<<-SQL, attr_hash)
        INSERT INTO
          #{self.class::TABLE} (#{insert_cols})
        VALUES
          (#{insert_vals})
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id

    else
      QuestionsDatabase.instance.execute(<<-SQL, attr_hash)
        UPDATE
          #{self.class::TABLE}
          SET #{update_string}
        WHERE
          id = :id
      SQL
    end

   end

   def insert_cols
     attr_hash.keys.inject('') { |string, key| string + ', ' + key}.sub(/, /,'')
   end

   def insert_vals
     attr_hash.keys.inject('') { |string, key| string + ', :' + key}.sub(/, /,'')
   end

   def update_string
     attr_hash.keys.inject('') { |string, key| string + ', ' + key + " = :" + key }.sub(/, /,'')
   end

   def attr_hash
     hash = {}
     self.instance_variables.each do |var|
         var_name = var[1..-1]
         value = self.send(var_name)
         hash[var_name] = value if value
     end

     hash
   end

end
