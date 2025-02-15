class Gc::QuestionOptionsController < GcController
    authorize_resource
  
    # POST /groups/1/questions/1/question_options
    def create
        @question = Question.find(params[:question_id])
        @question_option = QuestionOption.new(question_option_params)
        @question_option.question_id = @question.id
        @question_option.save
      
        respond_to do |format|
            format.html do 
                redirect_to(edit_gc_question_url(@question)) 
            end
        end
    end
  
    # DELETE /groups/1/questions/1/question_options/1
    def destroy
        @question = Question.find(params[:question_id])
        @question_option = QuestionOption.find(params[:id])
  
        @question.question_options.destroy(@question_option)
      
        respond_to do |format|
            format.html do 
                redirect_to(edit_gc_question_url(@question)) 
            end
        end
    end
  
    # PATCH /groups/1/questions/1/question_options/1/move_up
    def move_up
        @question = Question.find(params[:question_id])
        @question_option = QuestionOption.find(params[:id])

        respond_to do |format|
            @question_option.move_up!
            format.html { redirect_to edit_gc_question_url(@question) }
        end
    end

    # PATCH /groups/1/questions/1/question_options/1/move_down
    def move_down
        @question = Question.find(params[:question_id])
        @question_option = QuestionOption.find(params[:id])

        respond_to do |format|
            @question_option.move_down!
            format.html { redirect_to edit_gc_question_url(@question) }
        end
    end

  private
  
    def question_option_params
      params.require(:question_option).permit(
        :name
      )
    end
end
  