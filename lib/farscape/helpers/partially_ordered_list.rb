# Convenience class that finds an order for a set of elements that satisfies an arbitrary sorting function that
# can be undefined for some pairs.
# TODO: Optimize and gemify (or find existing gem that does this)

class PartiallyOrderedList
  include Enumerable

  class Element < Struct.new(:item, :preceders)
    def inspect
      if preceders.any?
        "#{item} > {#{preceders.map(&:item).join(', ')}}"
      else
        item
      end
    end
    def ==(other)
      item == other.item
    end
  end

  CircularOrderingError = Class.new(StandardError)

  attr_accessor :elements, :ordering

  def initialize(&block)
    raise ArgumentError, "#{self.class}.new requires a block" unless block_given?
    @elements = []
    @ordering = block
  end

  def add(item)
    @cached_ary = nil
    new_el = Element.new(item, [])
    elements.each do |old_el|
      case ordering.call(old_el.item, new_el.item)
      when -1
        new_el.preceders << old_el
      when 1
        old_el.preceders << new_el
      end
    end
    elements << new_el
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
      unadded = elements.map{ |elt| elt=elt.dup; elt.preceders = elt.preceders.dup; elt }
      while unadded.any?
        i = unadded.find_index { |candidate| candidate.preceders.none? }
        if i
          to_add = unadded.delete_at(i)
          yield(to_add.item)
          unadded.each { |elt| elt.preceders.delete(to_add) }
          @cached_ary << to_add
        else
          raise CircularOrderingError.new("Could not resolve ordering for #{unadded.map(&:item)}")
        end
      end
    end
  end

end
