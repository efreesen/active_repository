require 'set'

shared_examples "=" do
  context "when attribute is string" do
    it "matches a record" do
      record = Country.where("name = 'US'")
      record.count.should == 1
      record.first.id.should == 1
      record.first.name.should == 'US'
    end

    it "doesn't match any record" do
      record = Country.where("name = 'Argentina'")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is integer" do
    it "matches a record" do
      record = Country.where("id = 1")
      record.count.should == 1
      record.first.id.should == 1
      record.first.name.should == 'US'
    end

    it "doesn't match any record" do
      record = Country.where("id = 43")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is datetime" do
    it "matches a record" do
      record = Country.where("founded_at = ?", Time.parse('1500-04-22 13:34:25'))
      record.count.should == 1
      record.first.id.should == 5
      record.first.name.should == 'Brazil'
    end

    it "doesn't match any record" do
      record = Country.where("id = ?", Time.parse('1500-09-07 13:34:25'))
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples ">" do
  context "when attribute is a string" do
    it "matches a record" do
      records = Country.where("name > 'T'")
      records.count.should == 2
      records.first.id.should == 1
      records.should == [Country.find(1), Country.find(4)]
    end

    it "doesn't match any record" do
      record = Country.where("name > 'Z'")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is integer" do
    it "matches a record" do
      records = Country.where("id > 3")
      records.count.should == 2
      records.first.id.should == 4
      records.should == [Country.find(4), Country.find(5)]
    end

    it "doesn't match any record" do
      record = Country.where("id > 5")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is datetime" do
    it "matches a record" do
      record = Country.where("founded_at > ?", Time.parse('1500-04-20 13:34:25'))
      record.count.should == 1
      record.first.id.should == 5
      record.first.name.should == 'Brazil'
    end

    it "doesn't match any record" do
      record = Country.where("founded_at > ?", Time.parse('1500-04-23 13:34:25'))
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples ">=" do
  context "when attribute is a string" do
    it "matches a record" do
      records = Country.where("name >= 'U'")
      records.count.should == 2
      records.first.id.should == 1
      records.should == [Country.find(1), Country.find(4)]
    end

    it "doesn't match any record" do
      record = Country.where("name >= 'Z'")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is integer" do
    it "matches a record" do
      records = Country.where("id >= 4")
      records.count.should == 2
      records.first.id.should == 4
      records.should == [Country.find(4), Country.find(5)]
    end

    it "doesn't match any record" do
      record = Country.where("id >= 6")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is datetime" do
    it "matches a record" do
      record = Country.where("founded_at >= ?", Time.parse('1500-04-22 13:34:25'))
      record.count.should == 1
      record.first.id.should == 5
      record.first.name.should == 'Brazil'
    end

    it "doesn't match any record" do
      record = Country.where("founded_at >= ?", Time.parse('1500-04-23 13:34:25'))
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples "<" do
  context "when attribute is a string" do
    it "matches a record" do
      records = Country.where("name < 'C'")
      records.count.should == 1
      records.first.id.should == 5
      records.should == [Country.find(5)]
    end

    it "doesn't match any record" do
      record = Country.where("name < 'B'")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is integer" do
    it "matches a record" do
      records = Country.where("id < 3")
      records.count.should == 2
      records.first.id.should == 1
      records.should == [Country.find(1), Country.find(2)]
    end

    it "doesn't match any record" do
      record = Country.where("id < 1")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is datetime" do
    it "matches a record" do
      record = Country.where("founded_at < ?", Time.parse('1500-04-22 13:34:26'))
      record.count.should == 1
      record.first.id.should == 5
      record.first.name.should == 'Brazil'
    end

    it "doesn't match any record" do
      record = Country.where("founded_at < ?", Time.parse('1500-04-22 13:34:25'))
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples "<=" do
  context "when attribute is a string" do
    it "matches a record" do
      records = Country.where("name <= 'Brb'")
      records.count.should == 1
      records.first.id.should == 5
      records.should == [Country.find(5)]
    end

    it "doesn't match any record" do
      record = Country.where("name <= 'A'")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is integer" do
    it "matches a record" do
      records = Country.where("id <= 2")
      records.count.should == 2
      records.first.id.should == 1
      records.should == [Country.find(1), Country.find(2)]
    end

    it "doesn't match any record" do
      record = Country.where("id <= 0")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is datetime" do
    it "matches a record" do
      record = Country.where("founded_at <= ?", Time.parse('1500-04-22 13:34:25'))
      record.count.should == 1
      record.first.id.should == 5
      record.first.name.should == 'Brazil'
    end

    it "doesn't match any record" do
      record = Country.where("founded_at <= ?", Time.parse('1500-04-22 13:34:24'))
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples "between" do
  context "when attribute is a string" do
    it "matches a record" do
      records = Country.where("name between 'A' and 'C'")
      records.count.should == 1
      records.first.id.should == 5
      records.should == [Country.find(5)]
    end

    it "doesn't match any record" do
      record = Country.where("name between 'K' and 'M'")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is integer" do
    it "matches a record" do
      records = Country.where("id between 1 and 2")
      records.count.should == 2
      records.first.id.should == 1
      records.should == [Country.find(1), Country.find(2)]
    end

    it "doesn't match any record" do
      record = Country.where("id between 6 and 10")
      record.count.should == 0
      record.should == []
    end
  end

  context "when attribute is datetime" do
    it "matches a record" do
      record = Country.where("founded_at between ? and ?", Time.parse('1500-04-22 13:34:24'), Time.parse('1500-04-22 13:34:26'))
      record.count.should == 1
      record.first.id.should == 5
      record.first.name.should == 'Brazil'
    end

    it "doesn't match any record" do
      record = Country.where("founded_at between ? and ?", Time.parse('1500-04-22 13:34:26'), Time.parse('1500-09-22 13:34:25'))
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples "is" do
  it "attribute is condition" do
    records = Country.where("founded_at is null")
    records.count.should == 4
    records.first.id.should == 1
    records.should == [Country.find(1), Country.find(2), Country.find(3), Country.find(4)]
  end

  it "attribute is not condition" do
    id = Country.last.id
    records = Country.where("founded_at is not null")
    records.count.should == 1
    records.first.id.should == id
    records.should == [Country.find(id)]
  end
end

shared_examples "and" do
  it "attribute and condition" do
    records = Country.where("language = 'English' and monarch = 'The Crown of England'")
    records.count.should == 2
    records.first.id.should == 2
    records.should == [Country.find(2), Country.find(4)]
  end
end

shared_examples "or" do
  it "attribute or condition" do
    records = Country.where("language = 'English' or language = 'Spanish'")
    records.count.should == 4
    records.first.id.should == 1
    records.should == [Country.find(1), Country.find(2), Country.find(3), Country.find(4)]
  end
end