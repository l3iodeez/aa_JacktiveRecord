class Reply < ModelBase

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_id(id)
    options_hash = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    Reply.new(options_hash.first)
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :question_id, :user_id, :parent_id, :body

  def initialize(options = {})
    @question_id = options['question_id']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
    @body = options['body']
    @id = options['id']
  end

  def create
    raise 'already saved!' unless self.id.nil?
    params = { question_id: self.question_id, user_id: self.user_id, parent_id: self.parent_id, body: self.body}

    QuestionsDatabase.instance.execute(<<-SQL, params)
      INSERT INTO
        replies (question_id, user_id, parent_id, body)
      VALUES
        (:question_id, :user_id, :parent_id, :body)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

end
