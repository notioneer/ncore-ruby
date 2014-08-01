module MyApi
  class Customer < Resource
    crud :all, :find, :create, :update, :delete

    # has_many :users

  end
end
