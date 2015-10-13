require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database

  include Singleton

  def initialize

    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class User
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end

  def self.find_by_id(id)
    options_hash = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL
    User.new(options_hash)
  end

  def self.find_by_name(fname, lname)
    options_hash = QuestionsDatabase.instance.execute(<<-SQL, { fname: fname, lname: lname } )
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = :fname AND
        users.lname = :lname

    SQL
    User.new(options_hash)
  end

  attr_accessor :id, :fname, :lname
  # attr_reader :id

  def initialize(options = {})
    @fname = options['fname']
    @lname = options['lname']
    @id = options['id']
  end

  def create
    raise 'already saved!' unless self.id.nil?

    params = [self.fname, self.lname]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    
  @id = QuestionsDatabase.instance.last_insert_row_id
  end

end

class Question
end

class Question_follow
end

class Reply
end

class Question_like
end
