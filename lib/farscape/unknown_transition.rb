module Farscape
  # This error happens whenever the client tries to access a transition which is not there
  class UnknownTransition < StandardError
  end
end