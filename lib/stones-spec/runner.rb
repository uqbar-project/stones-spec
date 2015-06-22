module StonesSpec
  class Runner
    include StonesSpec::WithTempfile

    attr_reader :language

    def initialize(language)
      @language = language
    end

    def run!(test_definition)
      subject = Subject.from(test_definition[:subject], language)
      source = test_definition[:source]
      check_head_position = test_definition[:check_head_position]
      show_initial_board = test_definition.fetch(:show_initial_board, true)

      results = test_definition[:examples].map do |example_definition|
        run_example!(example_definition, check_head_position, show_initial_board, source, subject)
      end
      aggregate_results(results)
    end

    private

    def test_program(source, subject)
      language.test_program(source, subject)
    end

    def run_example!(example_definition, check_head_position, show_initial_board, source, subject)
      example = StonesSpec::Example.new(language, subject, example_definition)
      example.start!(
          source,
          Precondition.new(example),
          Postcondition.from(example, check_head_position, show_initial_board))
      example.result
    ensure
      example.stop!
    end

    def aggregate_results(results)
      [results.map { |it| it[0] }.join("\n<hr>\n"), results.all? { |it| it[1] == :passed } ? :passed : :failed]
    end
  end
end
