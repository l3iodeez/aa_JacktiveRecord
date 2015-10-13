

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

    User.new(options_hash.first)
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

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    avg_karma = QuestionsDatabase.instance.execute(<<-SQL, self.id )
    SELECT
      users.id,
      COALESCE(COUNT(question_likes.id) / CAST(COUNT(DISTINCT questions.id) AS FLOAT), 0) AS Avg
    FROM
      users
      LEFT OUTER JOIN
        questions ON (users.id = questions.user_id)
      LEFT OUTER JOIN
        question_likes ON (questions.id = question_likes.question_id)
    WHERE
      users.id = ?
    GROUP BY
      users.id
    SQL

    avg_karma[0]['Avg']
  end

end
