Rails.application.routes.draw do
  get 'game' => 'play#game'

  get 'score' => 'play#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
