module SqlStatement
	class << self
	    #this returns the sql query needed for company courses questions report page
	    def sql_statement_for_questions_reports_by_enterprise(enterprise_id)
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
		        WHERE course_questions.course_id IN (SELECT courses.id from courses where courses.enterprise_id = #{enterprise_id})
		        AND   course_assessments.course_id IN (SELECT courses.id from courses where courses.enterprise_id = #{enterprise_id})
		        AND   course_assessments.state = 'completed'
		        HAVING answer IS NOT NULL
		        ORDER BY question ASC, user_full_name ASC, assessment_id ASC"
	      

	        return sql
      end


      def sql_statement_for_ent_specific_reports enterprise_id, course_id
        user_ids = User.for_enterprise(enterprise_id).map(&:id).join(',')
        sql = " Select assignments.updated_at as date_taken, assignments.user_id as user_id, assignments.course_id as course_id,
          (
            SELECT CONCAT_WS(' ' , users.first_name, users.last_name)
            from users
            where users.id = assignments.user_id
          ) as user_full_name,
          (
            SELECT max(course_assessments.score) from course_assessments
            where course_assessments.user_id = assignments.user_id
            AND course_assessments.course_id = assignments.course_id
            AND course_assessments.state = 'completed'

          ) as heigher_score,
          (
            SELECT max(course_assessments.updated_at) from course_assessments
            where course_assessments.user_id = assignments.user_id
            AND course_assessments.course_id = assignments.course_id
            AND course_assessments.state = 'completed'
          ) as last_assessment
          from assignments
          where assignments.course_id = #{course_id}
          AND assignments.user_id IN (#{user_ids})

          order by user_full_name ASC"
        return sql
      end

    def sql_statement_for_company_courses_reports(company_id, interval_select)
      courses_ids = Course.where(enterprise_id: company_id).map(&:id).join(',')
      sql =" SELECT id as course_id, name, assig.completed_counter, cas.counter
      FROM courses c
      LEFT JOIN
      (SELECT course_id, COUNT(id) as completed_counter FROM assignments a where state = 2 #{interval_select} GROUP BY course_id) AS assig
      ON c.id = assig.course_id
      LEFT JOIN
      (SELECT course_id, COUNT(id) as counter FROM course_assessments ca where state = 'completed' #{interval_select} GROUP BY course_id) AS cas
      ON c.id = cas.course_id
      WHERE c.id IN (#{courses_ids})
      ORDER BY c.name"

      return sql
    end
  end
end
