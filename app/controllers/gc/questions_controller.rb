class Gc::QuestionsController < GcController
    load_and_authorize_resource
  
    # GET /gc/questions
    def index
      @questions = @group.questions.
        order(:section, :order_number).load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end

    # GET /gc/questions/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/questions/new
    def new
      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/questions/1/edit
    def edit
      @question_option = QuestionOption.new

      render layout: @current_role.name
    end
  
    # POST /admin/questions
    def create
      @question = Question.new(question_params)
      @question.group_id = @group.id

      respond_to do |format|
          if @question.save
              flash[:notice] = 'Question was successfully created.'
              @question_option = QuestionOption.new
              format.html { render action: "edit", layout: @current_role.name }
          else
              format.html { render action: "new", layout: @current_role.name }
          end
      end
    end

    # PATCH /gc/questions/1
    def update
        respond_to do |format|
          if @question.update(question_params)
            flash[:notice] = 'Question was successfully updated.'
            format.html { redirect_to gc_questions_url }
          else
            @question_option = QuestionOption.new
            format.html { render action: "edit", layout: @current_role.name }
          end
        end
    end
  
    # PATCH /gc/questions/1/move_up
    def move_up
      respond_to do |format|
        @question.move_up!
        format.html { redirect_to gc_questions_url }
      end
    end

    # PATCH /gc/questions/1/move_down
    def move_down
      respond_to do |format|
        @question.move_down!
        format.html { redirect_to gc_questions_url }
      end
    end

  # DELETE /gc/questions/1
    def destroy
        flash[:notice] = 'Question deleted.'
        @question.destroy

        respond_to do |format|
            format.html { redirect_to gc_questions_url }
        end
    end
  
    private
  
    def question_params
      params.require(:question).permit(
        :name,
        :required,
        :title, 
        :description, 
        :question_type,
        :section
      )
    end
end
  