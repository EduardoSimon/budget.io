require "test_helper"

class MovementsControllerTest < ActionDispatch::IntegrationTest
 class DateInPartialTest < ActionDispatch::IntegrationTest
   test "when date is provided renders the 'new' partial with it" do
     date = Date.today.prev_month
     get "/movements/new", params: { date: date  }

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

 class ReferrerRedirectionTest < ActionDispatch::IntegrationTest
   setup do
     @account = create(:account)
     @budget = create(:budget)
   end

   test "when the referrer is not present redirects to account view" do
     movement_params = attributes_for(:movement)
     post "/movements",
       params: {
         movement: movement_params.merge(account_id: @account.id)
       }

       assert_redirected_to account_url(@account)
   end
   test "when the referrer is present redirects to the referrer path" do
     movement_params = attributes_for(:movement)
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
end

