# frozen_string_literal: true

module Dslblend
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 3

    EDGE = false

    LABEL = [MAJOR, MINOR, PATCH, EDGE ? 'edge' : nil].compact.join('.')
  end
end
