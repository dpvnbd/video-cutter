RSpec.shared_context "api key auth" do
  let("X-Api-Key") do
    if respond_to?(:user)
      user.api_key
    else
      nil
    end
  end
end