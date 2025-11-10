require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_inclusion_of(:action).in_array(%w[read write update delete]) }
    it { should validate_presence_of(:entity_type) }
    it { should validate_presence_of(:entity_id) }
  end

  describe '.log_access' do
    let(:parent) { Parent.create!(email: 'test@example.com', first_name: 'John', last_name: 'Doe') }
    let(:student) { Student.create!(parent: parent, first_name: 'Jane', last_name: 'Doe', date_of_birth: 10.years.ago) }

    it 'creates an audit log entry' do
      expect {
        AuditLog.log_access(
          actor: parent,
          action: 'read',
          entity: student
        )
      }.to change(AuditLog, :count).by(1)

      log = AuditLog.last
      expect(log.actor_id).to eq(parent.id)
      expect(log.actor_type).to eq('Parent')
      expect(log.action).to eq('read')
      expect(log.entity_type).to eq('Student')
      expect(log.entity_id).to eq(student.id)
    end

    it 'records before and after state' do
      before_state = { status: 'draft' }
      after_state = { status: 'active' }

      log = AuditLog.log_access(
        actor: parent,
        action: 'update',
        entity: student,
        before: before_state,
        after: after_state
      )

      expect(log.before_json).to eq(before_state)
      expect(log.after_json).to eq(after_state)
    end
  end

  describe 'immutability' do
    let(:parent) { Parent.create!(email: 'test@example.com', first_name: 'John', last_name: 'Doe') }
    let(:student) { Student.create!(parent: parent, first_name: 'Jane', last_name: 'Doe', date_of_birth: 10.years.ago) }
    
    it 'is readonly after creation' do
      log = AuditLog.log_access(actor: parent, action: 'read', entity: student)
      expect(log).to be_readonly
    end

    it 'raises error when attempting to destroy' do
      log = AuditLog.log_access(actor: parent, action: 'read', entity: student)
      
      expect {
        log.destroy
      }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end

