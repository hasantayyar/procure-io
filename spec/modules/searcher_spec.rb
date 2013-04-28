require_relative '../support/no_rails_tests'
require_relative '../../lib/searcher'

describe Searcher do

  before do
    NoRailsTests.send(:remove_const, :"Model") if defined?(NoRailsTests::Model)
    class NoRailsTests::Model < NoRailsTests::FakeModel
      include Searcher
    end

    stub_const("PgSearch", Module.new)
  end

  describe 'has_searcher' do
    it 'defines self#searcher_starting_query if passed a starting query' do
      NoRailsTests::Model.has_searcher starting_query: "Foo"
      NoRailsTests::Model.searcher_starting_query.should == "Foo"
    end

    it 'does not define self#searcher_starting_query if not passed a starting query' do
      NoRailsTests::Model.has_searcher
      NoRailsTests::Model.should_not respond_to(:searcher_starting_query)
    end

    it 'defines self#searcher' do
      NoRailsTests::Model.has_searcher
      NoRailsTests::Model.should respond_to(:searcher)
    end
  end

  describe '#searcher' do
    it 'adds params to query' do
      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(0)
      NoRailsTests::Model.searcher({}, {})
    end

    it 'can return query for chaining' do
      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(0)
      NoRailsTests::Model.searcher({}, {chainable: true}).should == q
    end

    it 'can return the count' do
      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(0)
      NoRailsTests::Model.searcher({}, {count_only: true}).should == 0
    end

    it 'adds search_meta_info if necessary' do
      class NoRailsTests::Model
        def search_meta_info(*args)
        end
      end

      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(0)
      NoRailsTests::Model.should_receive(:search_meta_info).and_return({})
      NoRailsTests::Model.searcher({}, {})
    end

    it 'does not add search_meta_info if not necessary' do
      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(0)
      NoRailsTests::Model.stub(:respond_to?).and_return(false)
      NoRailsTests::Model.should_not_receive(:search_meta_info).and_return({})
      NoRailsTests::Model.searcher({}, {})
    end

    it 'returns the complete return_object' do
      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(5)
      result = NoRailsTests::Model.searcher({}, {})

      result[:meta][:total].should == 5
      result[:meta][:last_page].should == 1
      result[:meta][:page].should == 1
      result[:results].should == q
    end

    it 'should paginate properly' do
      NoRailsTests::Model.has_searcher starting_query: OpenStruct.new
      NoRailsTests::Model.should_receive(:add_params_to_query).and_return(q = NoRailsTests::FakeQuery.new)
      q.stub(:count).and_return(15)
      result = NoRailsTests::Model.searcher({page: 3}, {})

      result[:meta][:total].should == 15
      result[:meta][:last_page].should == 2
      result[:meta][:page].should == 2
      result[:results].should == q
    end
  end

end
