# Required until https://github.com/rubinius/rubinius/issues/2430 is resolved
ENV['RBXOPT'] = "#{ENV["RBXOPT"]} -Xcompiler.no_rbc"
