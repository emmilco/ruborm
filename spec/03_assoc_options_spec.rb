require '03_assoc_options'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('house')

      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq('House')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('owner',
                                     foreign_key: :human_id,
                                     class_name: 'Human',
                                     primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Human')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('cats', 'Human')

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Cat')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('cats', 'Human',
                                   foreign_key: :owner_id,
                                   class_name: 'Kitten',
                                   primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq('Kitten')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Cat < SQLObject
        self.finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('human')
      expect(options.model_class).to eq(Human)

      options = HasManyOptions.new('cats', 'Human')
      expect(options.model_class).to eq(Cat)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('human')
      expect(options.table_name).to eq('humans')

      options = HasManyOptions.new('cats', 'Human')
      expect(options.table_name).to eq('cats')
    end
  end
end
