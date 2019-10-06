RSpec.shared_context "api key auth" do
  let("X-Api-Key") do
    if respond_to?(:signed_in_user)
      signed_in_user.api_key
    else
      nil
    end
  end
end