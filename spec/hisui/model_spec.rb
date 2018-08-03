describe Hisui::Model do
  context "A Class extended with Hisui::Model" do
    let!(:model_class) { Class.new.tap { |klass| klass.extend(Hisui::Model) } }

    context '.metrics' do
      it 'has a metric' do
        model_class.metrics :pageviews

        expect(model_class.metrics).to eq(Set.new([expression: 'ga:pageviews']))
      end

      it 'has metrics' do
        model_class.metrics :pageviews, :sessions

        expect(model_class.metrics).to eq(Set.new([{ expression: 'ga:pageviews'}, { expression: 'ga:sessions'}]))
      end

      it 'does not add duplicated metrics' do
        model_class.metrics :pageviews, :sessions
        model_class.metrics :sessions
        model_class.metrics :sessions, :sessions

        expect(model_class.metrics).to eq(Set.new([{ expression: 'ga:pageviews'}, { expression: 'ga:sessions'}]))
      end
    end

    context '.dimensions' do
      it 'has a dimension' do
        model_class.dimensions :medium

        expect(model_class.dimensions).to eq(Set.new([name: 'ga:medium']))
      end

      it 'has dimensions' do
        model_class.dimensions :medium, :source

        expect(model_class.dimensions).to eq(Set.new([{ name: 'ga:medium'}, { name: 'ga:source'}]))
      end

      it 'does not add duplicated dimensions' do
        model_class.dimensions :medium, :source
        model_class.dimensions :source
        model_class.dimensions :source, :source

        expect(model_class.dimensions).to eq(Set.new([{ name: 'ga:medium'}, { name: 'ga:source'}]))
      end
    end

    context '.order_bys' do
      it 'has a order by' do
        model_class.order_bys({ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' })

        expect(model_class.order_bys).to eq(Set.new([{ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' }]))
      end

      it 'has order bys' do
        model_class.order_bys({ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' })
        model_class.order_bys({ field_name: 'ga:users', order_type: 'VALUE', sort_order: 'ASCENDING' })

        expect(model_class.order_bys).to eq(Set.new([{ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' }, { field_name: 'ga:users', order_type: 'VALUE', sort_order: 'ASCENDING' }]))
      end

      it 'does not add duplicated order bys' do
        model_class.order_bys({ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' })
        model_class.order_bys({ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' })

        expect(model_class.order_bys).to eq(Set.new([{ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' }]))
      end
    end

    context '.filters_expression' do
      it 'has a filters expression' do
        model_class.filters_expression({ field_name: 'device_category', operator: '==', value: 'desktop' })

        expect(model_class.filters_expression).to eq('ga:deviceCategory==desktop')
      end
    end

    context '.results' do
      let!(:user) { Hisui::User.new(access_token) }
      let!(:profile) { user.profiles[5] }

      context 'when date range is one' do
        it 'has results' do
          model_class.metrics :pageviews, :sessions
          model_class.dimensions :medium
          model_class.order_bys({ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' })
          results = model_class.results(profile: profile, start_date: Date.new(2017, 10, 1), end_date: Date.new(2017, 10, 31))

          expect(results.data?).to be(true)
          expect(results.primary.first).to respond_to(:medium)
          expect(results.primary.first).to respond_to(:pageviews)
          expect(results.primary.first).to respond_to(:sessions)
          expect(results.primary_total).to respond_to(:pageviews)
          expect(results.primary_total).to respond_to(:sessions)

          expect(results.comparing.first).to respond_to(:medium)
          expect(results.comparing.first).to respond_to(:pageviews)
          expect(results.comparing.first).to respond_to(:sessions)
          expect(results.comparing_total).to respond_to(:pageviews)
          expect(results.comparing_total).to respond_to(:sessions)

          expect(results.rows.first).to respond_to(:dimensions)
          expect(results.rows.first.primary).to respond_to(:pageviews)
          expect(results.rows.first.primary).to respond_to(:sessions)
          expect(results.rows.first.comparing).to respond_to(:pageviews)
          expect(results.rows.first.comparing).to respond_to(:sessions)
        end
      end

      context 'when date ranges are two' do
        it 'has results' do
          model_class.metrics :pageviews, :sessions
          model_class.dimensions :medium
          model_class.order_bys({ field_name: 'ga:sessions', order_type: 'VALUE', sort_order: 'DESCENDING' })
          results = model_class.results(
            profile: profile,
            start_date: Date.new(2017, 10, 1),
            end_date: Date.new(2017, 10, 31),
            comparing_start_date: Date.new(2017, 9, 1),
            comparing_end_date: Date.new(2017, 9, 30)
          )

          expect(results.data?).to be(true)

          expect(results.primary.first).to respond_to(:medium)
          expect(results.primary.first).to respond_to(:pageviews)
          expect(results.primary.first).to respond_to(:sessions)
          expect(results.primary_total).to respond_to(:pageviews)
          expect(results.primary_total).to respond_to(:sessions)

          expect(results.comparing.first).to respond_to(:medium)
          expect(results.comparing.first).to respond_to(:pageviews)
          expect(results.comparing.first).to respond_to(:sessions)
          expect(results.comparing_total).to respond_to(:pageviews)
          expect(results.comparing_total).to respond_to(:sessions)

          expect(results.rows.first).to respond_to(:dimensions)
          expect(results.rows.first.primary).to respond_to(:pageviews)
          expect(results.rows.first.primary).to respond_to(:sessions)
          expect(results.rows.first.comparing).to respond_to(:pageviews)
          expect(results.rows.first.comparing).to respond_to(:sessions)
        end
      end

      context 'when filters_expression is set' do
        it 'has results' do
          model_class.metrics :pageviews, :sessions
          model_class.dimensions :medium
          model_class.filters_expression({ field_name: 'medium', operator: '==', value: 'organic' })
          results = model_class.results(profile: profile, start_date: Date.new(2017, 10, 1), end_date: Date.new(2017, 10, 31))

          expect(results.data?).to be(true)
          expect(results.primary.count).to eq(1)
          expect(results.primary.first.medium).to eq('organic')
        end
      end
    end
  end
end
