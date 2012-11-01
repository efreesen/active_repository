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
      record = Country.where("id = 43")
      record.count.should == 0
      record.should == []
    end
  end
end

shared_examples ">" do
  it "attribute greater condition" do
    records = Country.where("id > 3")
    records.count.should == 2
    records.first.id.should == 4
    records.should == [Country.find(4), Country.find(5)]
  end
end

shared_examples ">=" do
  it "attribute greater or equal condition" do
    records = Country.where("id >= 3")
    records.count.should == 3
    records.first.id.should == 3
    records.should == [Country.find(3), Country.find(4), Country.find(5)]
  end
end

shared_examples "<" do
  it "attribute less condition" do
    records = Country.where("id < 3")
    records.count.should == 2
    records.first.id.should == 1
    records.should == [Country.find(1), Country.find(2)]
  end
end

shared_examples "<=" do
  it "attribute less or equal condition" do
    records = Country.where("id <= 3")
    records.count.should == 3
    records.first.id.should == 1
    records.should == [Country.find(1), Country.find(2), Country.find(3)]
  end
end

shared_examples "between" do
  it "attribute between condition" do
    records = Country.where("id between 2 and 4")
    records.count.should == 3
    records.first.id.should == 2
    records.should == [Country.find(2), Country.find(3), Country.find(4)]
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