require 'spec_helper'

credentials = {
    access_token: '4240~JdXebCtElIBHsTtITdcIZ4JSD6l6i9MlOej8CY288w88GbREWIdg4XI74m4UrlrP',
    host: 'https://softservepartnership.instructure.com'
}

describe Canvas do
  before :each do
    @api = Canvas::API.new(credentials)
  end

  context 'api' do

    context 'update section' do
      before :each do
        VCR.use_cassette 'section' do
          @section = @api.update_section(section_id: 1064,
                                         body: {
                                             course_section: {
                                                 end_at: "2015-09-13T21:00:00Z" } }
          )
        end
      end
      it 'should return array of submissions' do
        expect(@section.end_at).to eq "2015-09-13T21:00:00Z"
        expect(1 + 1).to eq 2
      end
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
        expect(@courses[0].name).to eq 'G integration'
      end
    end


    context 'course' do
      before :each do
        VCR.use_cassette 'course' do
          @course = @api.course course_id: 994
        end
      end

      it 'should return struct with attributes accessible as methods' do
        expect(@course.name).to eq 'G integration'
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
          @modules = @api.modules(course_id: 943)
        end
      end

      it 'should return array of elements' do
        expect(@modules.class).to eq Array
      end

      it 'array element should be a struct with attributes accessible as methods' do
        expect(@modules[0].name).to eq 'Present Module'
      end
    end


    context 'sections' do
      before :each do
        VCR.use_cassette 'sections' do
          @sections = @api.sections(course_id: 943)
        end
      end

      it 'should return array of elements' do
        expect(@sections.class).to eq Array
      end

      it 'array element should be a struct with attributes accessible as methods' do
        expect(@sections[0].name).to eq 'Presentation Course'
      end
    end


    context 'study_plan' do
      before :each do
        # @api = Canvas::API.new(credentials.merge({ cache: true }))
        VCR.use_cassette 'study_plan' do
          @study_plan = @api.study_plan(course_id: 943)
        end
      end

      xit 'should return array of modules' do
        expect(@study_plan.class).to eq Array
      end

      xit 'should contains modules which include items' do
        expect(@study_plan[0].items.class).to eq Array
        expect(@study_plan[0].items.size).not_to eq 0
      end
    end


    let(:account_id) { 41 }
    let(:enrollment_id) { 20371 }


    context 'enrollment' do

      it 'should return struct with attributes accessible as methods' do
        enrollment = nil
        VCR.use_cassette 'enrollment' do
          enrollment = @api.enrollment account_id: 1, enrollment_id: enrollment_id
        end
        expect(enrollment.id).to eq enrollment_id
      end

      it 'should return error without exception if non existing account retrieved' do
        enrollment_id = -1
        account = nil
        VCR.use_cassette 'enrollment_not_found' do
          account = @api.enrollment account_id: account_id, enrollment_id: enrollment_id
        end
        expect(account.errors[0]['message']).to eq 'The specified resource does not exist.'
      end
    end


    context 'enrollments' do
      before :each do
        VCR.use_cassette 'enrollments' do
          @enrollments = @api.enrollments(course_id: 943)
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
          expect(enrollments.size).to eq 18
          expect(enrollments[0].type).to eq 'StudentEnrollment'
        end

        VCR.use_cassette 'enrollments_with_params_nothing_found' do
          enrollments = @api.enrollments(course_id: 40, params: {type: 'TeacherEnrollment'})
          expect(enrollments.size).to eq 5
        end
      end
    end


    context 'submissions' do
      before :each do
        VCR.use_cassette 'submissions' do
          @submissions = @api.submissions(section_id: 973, assignment_id: 67)
        end
      end
      it 'should return array of submissions' do
        expect(@submissions.class).to eq Array
        expect(@submissions[0].workflow_state).to eq 'graded'
      end
    end


    context 'conclude_enrollment' do
      it 'returns the same enrollment' do
        concluded_enrollment = nil
        VCR.use_cassette 'conclude_enrollment' do
          concluded_enrollment = @api.conclude_enrollment(course_id: 943, enrollment_id: enrollment_id)
        end
        expect(concluded_enrollment.id).to eq enrollment_id
        expect(concluded_enrollment.enrollment_state).to eq 'completed'
      end
    end


    context 'admins' do
      it 'returns an Array of admins' do
        admins = nil
        VCR.use_cassette 'admins' do
          admins = @api.admins(account_id: account_id)
        end
        expect(admins).to be_an Array
      end

      it 'returns items with :id and :user attributes accessible as methods of a struct' do
        admins = nil
        VCR.use_cassette 'admins' do
          admins = @api.admins(account_id: account_id)
        end
        expect(admins[0].id).to eq 13
        expect(admins[0].user).to be_a Hash
      end
    end


    context 'account' do
      it 'should return struct with attributes accessible as methods' do
        account = nil
        VCR.use_cassette 'account' do
          account = @api.account account_id: account_id
        end
        expect(account.default_time_zone).to eq 'America/Denver'
      end

      it 'should return error without exception if non existing account retrieved' do
        account_id = -1
        account = nil
        VCR.use_cassette 'account_not_found' do
          account = @api.account account_id: -1
        end
        expect(account.errors[0]['message']).to eq 'The specified resource does not exist.'
      end
    end


    context 'create_conversation' do
      it 'returns created conversation' do
        body = {
            recipients: [2],
            subject:    'Test subject',
            body:       'Test body'
        }
        created_conversations = nil
        VCR.use_cassette 'created_conversation' do
          created_conversations = @api.create_conversation(body: body)
        end
        expect(created_conversations[0].id).to be > 0
      end
    end

  end
end