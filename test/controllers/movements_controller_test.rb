require "test_helper"

class MovementsControllerTest < ActionDispatch::IntegrationTest
  class BaseTestClass < ActionDispatch::IntegrationTest
    def setup
      MovementsController.class_variable_set(:@@referrer, nil)
    end
  end

 class DateInPartialTest < BaseTestClass
   test "when date is provided renders the 'new' partial with it" do
     date = Date.today.prev_month
     get "/movements/new", params: { movement: { created_at: date  } }

     assert_response :success

     assert_select "form input[type=date][value='#{date.strftime("%Y-%m-%d")}']"
   end

   test "when date is not provided renders the 'new' partial with todays date" do
     get "/movements/new"

     assert_response :success

     assert_date_select_is_empty
   end

   private

   def assert_date_select_is_empty
     ## An empty date selector will have the value set to today's date
     date_input = css_select('#movement_created_at').first
     assert_nil date_input['value']
   end
  end

 class ReferrerRedirectionTest < BaseTestClass
   setup do
     @account = create(:account)
     @budget = create(:budget)
   end

   test "when the referrer is not present redirects to account view" do
     movement_params = attributes_for(:movement, :with_amount)
     post "/movements",
       params: {
         movement: movement_params.merge(account_id: @account.id)
       }

     assert_redirected_to account_url(@account)
   end
   test "when the referrer is present redirects to the referrer path" do
     movement_params = attributes_for(:movement, :with_amount)
     get "/movements/new", 
       headers: {
         'HTTP_REFERER' => budget_url(@budget)
       }

     post "/movements",
       params: {
         movement: movement_params.merge(account_id: @account.id)
       }

     assert_redirected_to budget_url(@budget)
   end
 end

 class ViewTests < BaseTestClass
   test "shows an error for every required parameter" do
     post "/movements", params: { movement: { payer: nil, description: nil, account_id: nil} }


     assert_select "li", "Account must exist"
     assert_select "li", "Payer can't be blank"
     assert_select "span", "2 errors prohibited this movement from being saved:"
   end

   test "draws the model form" do
     get "/movements/new"

     assert_select "input[name='movement[payer]']"
     assert_select "textarea[name='movement[description]']"
     assert_select "input[name='movement[amount]']"
     assert_select "select[name='movement[account_id]']"
     assert_select "input[name='movement[created_at]']"
   end
 end
end

