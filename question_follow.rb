class QuestionFollow < ModelBase
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
    results.map { |result| QuestionFollow.new(result) }
  end

  def self.find_by_id(id)
    options_hash = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.id = ?
    SQL

    QuestionFollow.new(options_hash.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN users
        ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_follows
      ON question_follows.question_id = questions.id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  attr_accessor :id, :user_id, :question_id
  # attr_reader :id

  def initialize(options = {})
    @user_id = options['user_id']
    @question_id = options['question_id']
    @id = options['id']
  end

  def create
    raise 'already saved!' unless self.id.nil?

    params = [self.user_id, self.question_id]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end




end
