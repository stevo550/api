# require 'ruby-debug'
# require 'pry-debugger'

describe AlertPolicy do
  subject { AlertPolicy }

  let(:alert) { create :alert }
  let(:current_staff) { create :staff }
  let(:admin) { create :staff, :admin }

  permissions :index? do
    it 'allows access for a user' do
      expect(subject).to permit(current_staff)
    end

    it 'allows access for an admin' do
      expect(subject).to permit(admin)
    end
  end

  permissions :show? do
    it 'allows users to see alerts' do
      expect(subject).to permit(current_staff, alert)
    end
  end

  permissions :create? do
    it 'prevents creation if not an admin' do
      expect(subject).not_to permit(current_staff)
    end

    it 'allows an admin to create alerts' do
      expect(subject).to permit(admin)
    end
  end

  permissions :update? do
    it 'does not allow users to update alerts' do
      expect(subject).not_to permit(current_staff, alert)
    end

    it 'allows an admin to make updates' do
      expect(subject).to permit(admin, alert)
    end
  end

  permissions :destroy? do
    it 'does not allow users to delete alerts' do
      expect(subject).to_not permit(current_staff, alert)
    end

    it 'allows an admin to delete any alert' do
      expect(subject).to permit(admin, alert)
    end
  end
end
