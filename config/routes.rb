Rails.application.routes.draw do
  resource :players do
    get "search"
  end
end
