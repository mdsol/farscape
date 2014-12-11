require_relative '../../../lib/farscape/helpers/partially_ordered_list.rb'

describe(PartiallyOrderedList) do

  it 'sorts a list given a complete ordering' do
    list = described_class.new { |a,b| a <=> b }
    1.upto(10) { |i| list.add(i) }
    expect(list.to_a).to eq([*1..10])
  end

  it 'sorts a shuffled list given a complete ordering' do
    list = described_class.new { |a,b| a <=> b }
    [*1..10].shuffle.each { |i| list.add(i) }
    expect(list.to_a).to eq([*1..10])
  end

  it 'returns an arbitrary list when nothing is ordered' do
    list = described_class.new {}
    (1..20).each { |i| list.add(i) }
    expect(list.count).to eq(20)
  end


  it 'finds an order for a list satisfying a disjoint ordering' do
    list = described_class.new do |a,b|
      if a % 2 == b % 2
        a <=> b
      end
    end
    [*1..20].shuffle.each { |i| list.add(i) }
    expect(list.partition(&:odd?)).to eq([*1..20].partition(&:odd?))
  end

  it 'finds one possible transitive ordering' do
    list = described_class.new do |a,b|
      if a % 2 == b % 2
        a <=> b
      elsif [a,b] == [1,8]
        1
      elsif [a,b] == [8,1]
        -1
      end
    end
    [*1..20].shuffle.each { |i| list.add(i) }
    expect(list.partition(&:odd?)).to eq([*1..20].partition(&:odd?))
    expect(list.find_index(8)).to be < list.find_index(1)
  end

  it 'finds the only possible transitive ordering' do
    list = described_class.new do |a,b|
      if a % 2 == b % 2
        a <=> b
      elsif [a,b] == [1,20]
        1
      elsif [a,b] == [20,1]
        -1
      end
    end
    [*1..20].shuffle.each { |i| list.add(i) }
    expect(list.to_a).to eq([2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19])
  end

  it 'raises on circular ordering' do
    list = described_class.new do |a,b|
      if [a,b] == [1,10]
        1
      elsif [a,b] == [10,1]
        -1
      else
        a <=> b
      end
    end
    [*1..10].shuffle.each { |i| list.add(i) }
    expect{ list.to_a }.to raise_error(PartiallyOrderedList::CircularOrderingError)
  end

  it 'deletes' do
    list = described_class.new { |a,b| a <=> b }
    [*1..10].shuffle.each { |i| list.add(i) }
    list.delete(5)
    expect(list.to_a).to eq( [1,2,3,4,6,7,8,9,10] )
  end

  it 'deletes when there is a cached ordering' do
    list = described_class.new {}
    list.add 1
    list.add 2
    list.to_a
    list.delete 1
    expect(list.to_a).to eq([2])
  end

  it 'invalidates cached ordering when a new item is added' do
    list = described_class.new {}
    1.upto(10) { |i| list.add(i) }
    list.to_a
    list.add(11)
    expect(list.count).to eq(11)
  end

  it 'returns an enumerator when each is called without a block' do
    expect(described_class.new{}.each).to be_a(Enumerator)
  end

  it 'raises if new is called without a block' do
    expect{described_class.new}.to raise_error(ArgumentError)
  end

end
