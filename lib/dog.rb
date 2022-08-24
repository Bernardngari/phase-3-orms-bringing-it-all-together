class Dog
	attr_accessor :name, :breed, :id

	def initialize(name:, breed:, id: nil)
		@name = name
		@id = id
		@breed = breed
	end

	def self.create_table
		table = <<-SQL
		CREATE TABLE IF NOT EXISTS dogs(
		id INTEGER PRIMARY KEY,
		name TEXT,
		breed TEXT
		)
		SQL
		DB[:conn].execute(table)
	end

	def self.drop_table
		table = "DROP TABLE IF EXISTS dogs"
		DB[:conn].execute(table)
	end

	def save
		new_row = <<-SQL
			INSERT INTO dogs (name,breed)
			VALUES (?,?)
		SQL
		DB[:conn].execute(new_row, self.name, self.breed)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.create(name:, breed:)
			new_dog = Dog.new(name:name, breed:breed)
			new_dog.save
	end

	def self.new_from_db(row)
		self.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.all
		all_dogs = "SELECT * FROM dogs"
		DB[:conn].execute(all_dogs).map do |each_dog_row|
			self.new_from_db(each_dog_row)
		end
	end

	def self.find_by_name(name)
		sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.name = ?
        LIMIT 1;
      SQL

      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
	end

	def self.find(id)
		dog = "SELECT * FROM dogs WHERE dogs.id = ?"
		DB[:conn].execute(dog,id).map do |row|
		 self.new_from_db(row)
		end.first
	end

end
