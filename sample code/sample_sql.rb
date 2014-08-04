module SqlStatement
	class << self
	    #this returns the sql query needed for some reports 
	    def function_name(param)
	      	sql = "
		        SELECT  course_questions.id as question_id, course_questions.question_type, course_questions.body as question, course_assessments.user_id, course_assessments.id as assessment_id, 
		        (SELECT CONCAT_WS(' ' , users.first_name, users.last_name) 
		        from users
		        where users.id = course_assessments.user_id) as user_full_name,  
		        (SELECT
		          CASE
		            WHEN course_questions.question_type = 'true_or_false' 
		            THEN 
		              (SELECT course_assessment_answers.answer_body from course_assessment_answers 
		              WHERE course_assessment_answers.question_id = course_questions.id 
		              AND course_assessment_answers.course_assessment_id = assessment_id
		              AND course_assessment_answers.is_correct IS TRUE) 
		            WHEN course_questions.question_type = 'multiple_choice' 
		            THEN 
		              (SELECT GROUP_CONCAT(course_assessment_answers.answer_body SEPARATOR ';')
		              from course_assessment_answers 
		              WHERE course_assessment_answers.question_id = course_questions.id 
		              AND course_assessment_answers.course_assessment_id = assessment_id
		              AND course_assessment_answers.is_correct IS TRUE ) 
		            WHEN course_questions.question_type = 'correct_order' 
		            THEN 
		              (SELECT GROUP_CONCAT( CONCAT_WS('->', course_assessment_answers.answer_index, course_assessment_answers.answer_body)
		                SEPARATOR ';')
		              from course_assessment_answers 
		              WHERE course_assessment_answers.question_id = course_questions.id
		              AND course_assessment_answers.course_assessment_id = assessment_id
		              AND course_assessment_answers.is_correct IS TRUE ) 
		            WHEN course_questions.question_type = 'match_definitions' 
		            THEN 
		              (SELECT GROUP_CONCAT( CONCAT_WS('->', course_assessment_answers.statement_body, course_assessment_answers.answer_body)
		                SEPARATOR ';')
		              from course_assessment_answers 
		              WHERE course_assessment_answers.question_id = course_questions.id
		              AND course_assessment_answers.course_assessment_id = assessment_id
		              AND course_assessment_answers.is_correct IS TRUE )
		          END ) as answer
		        FROM course_questions,course_assessments 
		        WHERE course_questions.course_id IN (SELECT courses.id from courses where courses.enterprise_id = #{param})
		        AND   course_assessments.course_id IN (SELECT courses.id from courses where courses.enterprise_id = #{param})
		        AND   course_assessments.state = 'completed'
		        HAVING answer IS NOT NULL
		        ORDER BY question ASC, user_full_name ASC, assessment_id ASC"
	      

	        return sql
      end


      
end
