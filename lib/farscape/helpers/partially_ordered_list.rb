# Convenience class that finds an order for a set of elements that satisfies an arbitrary sorting function that
# can be undefined for some pairs.
# TODO: Optimize and gemify (or find existing gem that does this)

class PartiallyOrderedList
  include Enumerable

  class Element < Struct.new(:item, :preceders)
    def to_s
      if preceders.any?
        "#{item} > #{preceders.map(&:item).join(', ')}"
      else
        item
      end
    end
  end

  class CircularOrderingError < StandardError
  end

  attr_accessor :elements, :ordering

  def initialize(&block)
    raise ArgumentError, "#{self.class}.new requires a block" unless block_given?
    @elements = []
    @ordering = block
  end

  def add(item)
    @cached_ary = nil
    new = Element.new(item, [])
    elements.each do |old|
      case ordering.call(old.item, new.item)
      when -1
        new.preceders << old
      when 1
        old.preceders  << new
      end
    end
    elements << new
  end

  def delete(item)
    if element = elements.find { |elt| elt.item == item }
      elements.delete(element)
      @cached_ary.delete(element) if @cached_ary
      elements.each { |elt| elt.preceders.delete(element) }
      item
    end
  end

  def each(&block)
    return to_enum unless block_given?
    if @cached_ary && @cached_ary.size == elements.size
      @cached_ary.each{ |elt| yield elt.item }
    else
      @cached_ary = []
      unadded = elements.dup
      while unadded.any?
        i = unadded.find_index { |candidate| (candidate.preceders - @cached_ary).none? }
        if i
          to_add = unadded.delete_at(i)
          yield(to_add.item)
          @cached_ary << to_add
        else
          raise CircularOrderingError.new("Could not resolve ordering for #{unadded.map(&:item)}")
        end
      end
    end
  end

end
