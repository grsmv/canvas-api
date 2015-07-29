require 'spec_helper'

credentials = {
    access_token: 'zhFiPxnVg728KKFpDHs4UEJvuqDooEQIeBBsEjR6mX5rQRGlSJv9vTIrKjj2KYuf',
    host: 'https://softservepartnership.test.instructure.com'
}

describe Canvas do
  context 'auth' do

    xit 'should fail with incorrect credentials' do
      VCR.use_cassette 'incorrect_credentials' do
        expect do
          Canvas::API.new(access_token: 'incorrect-access-token',
                          host: 'https://softservepartnership.test.instructure.com').courses
        end.to raise_error(Exception)
      end
    end
  end

  context 'api' do

    before :each do
      @api = Canvas::API.new(credentials)
    end

    context 'courses' do
      before :each do
        VCR.use_cassette 'courses' do
          @courses = @api.courses
        end
      end

      it 'should return array of elements' do
        expect(@courses.class).to eq Array
      end

      it 'array element should be a struct with attributes accessible as methods' do
        expect(@courses[0].name).to eq 'Mns Tennis'
      end
    end


    context 'course' do
      before :each do
        VCR.use_cassette 'course' do
          @course = @api.course course_id: 40
        end
      end

      it 'should return struct with attributes accessible as methods' do
        expect(@course.name).to eq 'Mns Tennis'
      end

      it 'should return error without exception if non existing course retrieved' do
        VCR.use_cassette 'course_not_found' do
          course = @api.course course_id: 400000
          expect(course.errors[0]['message']).to eq 'The specified resource does not exist.'
        end
      end
    end


    context 'modules' do
      before :each do
        VCR.use_cassette 'modules' do
          @modules = @api.modules(course_id: 40)
        end
      end

      it 'should return array of elements' do
        expect(@modules.class).to eq Array
      end

      it 'array element should be a struct with attributes accessible as methods' do
        expect(@modules[0].name).to eq 'Introduction'
      end
    end


    context 'sections' do
      before :each do
        VCR.use_cassette 'sections' do
          @sections = @api.sections(course_id: 40)
        end
      end

      it 'should return array of elements' do
        expect(@sections.class).to eq Array
      end

      it 'array element should be a struct with attributes accessible as methods' do
        expect(@sections[0].name).to eq '9950054111'
      end
    end


    context 'study_plan' do
      before :each do
        VCR.use_cassette 'study_plan' do
          @study_plan = @api.study_plan(course_id: 40)
        end
      end

      it 'should return array of modules' do
        expect(@study_plan.class).to eq Array
      end

      it 'should contains modules which includes items' do
        expect(@study_plan[0].items.class).to eq Array
        expect(@study_plan[0].items.size).not_to eq 0
      end
    end


    context 'enrollments' do
      before :each do
        VCR.use_cassette 'enrollments' do
          @enrollments = @api.enrollments(course_id: 40)
        end
      end

      it 'should return array of enrollments' do
        expect(@enrollments.class).to eq Array
      end

      it 'array element should be a struct with attributes accessible as methods' do
        expect(@enrollments[0].type).to eq 'StudentEnrollment'
      end

      it 'should apply given query parameters' do
        VCR.use_cassette 'enrollments_with_params' do
          enrollments = @api.enrollments(course_id: 40, params: {type: 'StudentEnrollment'})
          expect(enrollments.size).to eq 6
          expect(enrollments[0].type).to eq 'StudentEnrollment'
        end

        VCR.use_cassette 'enrollments_with_params_nothing_found' do
          enrollments = @api.enrollments(course_id: 40, params: {type: 'TeacherEnrollment'})
          expect(enrollments.size).to eq 0
        end
      end
    end

    context 'submissions' do
      before :each do
        VCR.use_cassette 'submissions' do
          @submissions = @api.submissions(section_id: 936, assignment_id: 7)
        end
      end
      it 'should return array of submissions' do
        expect(@submissions.class).to eq Array
        expect(@submissions[0].workflow_state).to eq 'unsubmitted'
      end
    end

  end
end