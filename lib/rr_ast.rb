module RR::AST

  class Method
    attr_accesor :params , :name , :return_type, :children
  end

  class Block
    attr_accesor :inner_variables , :outer_variables ,:children
  end

  class Class
    attr_accesor :name ,  :parent_class , :methods ,:class_methods , :module ,:included_modules
  end

  class Module
    attr_reader :name , :module , :modules ,:classes , :methods , :constants
  end
end
