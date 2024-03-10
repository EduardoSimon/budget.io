require "test_helper"
require "rake"

class RetrieveRequisitionForAccountTestCase < ActiveSupport::TestCase
  describe "migration:retrieve_requisitions_for_account" do
    def setup
      ApplicationName::Application.load_tasks if Rake::Task.tasks.empty?
      Rake::Task["migration:retrieve_requisitions_for_account"].invoke
    end

    it "should change 'thing I don't want'" do
      @tt.reload
      values = @tt.attribute_i_changed
      refute_includes values, "thing I don't want"
      assert_includes values, "thing I do want"
    end
  end
end
