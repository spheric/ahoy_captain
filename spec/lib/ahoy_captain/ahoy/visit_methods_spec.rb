# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AhoyCaptain::Ahoy::VisitMethods do
  describe 'ransackers' do
    describe 'ref_domain' do
      it 'is defined as a ransacker' do
        expect(Ahoy::Visit.ransackable_attributes).to include('ref_domain')
      end

      it 'extracts domain from referring_domain without protocol' do
        create(:ahoy_visit, referring_domain: 'example.com')
        create(:ahoy_visit, referring_domain: 'other.com')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('example.com')
      end

      it 'extracts domain from referring_domain with http protocol' do
        create(:ahoy_visit, referring_domain: 'http://example.com')
        create(:ahoy_visit, referring_domain: 'http://other.com')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('http://example.com')
      end

      it 'extracts domain from referring_domain with https protocol' do
        create(:ahoy_visit, referring_domain: 'https://example.com')
        create(:ahoy_visit, referring_domain: 'https://other.com')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('https://example.com')
      end

      it 'strips www prefix from domain' do
        create(:ahoy_visit, referring_domain: 'www.example.com')
        create(:ahoy_visit, referring_domain: 'www.other.com')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('www.example.com')
      end

      it 'strips www prefix with protocol' do
        create(:ahoy_visit, referring_domain: 'https://www.example.com')
        create(:ahoy_visit, referring_domain: 'https://www.other.com')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('https://www.example.com')
      end

      it 'stops at path separator' do
        create(:ahoy_visit, referring_domain: 'example.com/path')
        create(:ahoy_visit, referring_domain: 'other.com/path')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('example.com/path')
      end

      it 'stops at query separator' do
        create(:ahoy_visit, referring_domain: 'example.com?query=1')
        create(:ahoy_visit, referring_domain: 'other.com?query=1')

        result = Ahoy::Visit.ransack(ref_domain_eq: 'example.com').result

        expect(result.count).to eq(1)
        expect(result.first.referring_domain).to eq('example.com?query=1')
      end
    end
  end

  describe '.ransackable_attributes' do
    it 'includes all column names' do
      column_names = Ahoy::Visit.columns_hash.keys
      ransackable = Ahoy::Visit.ransackable_attributes

      column_names.each do |column|
        expect(ransackable).to include(column)
      end
    end

    it 'includes ref_domain ransacker' do
      expect(Ahoy::Visit.ransackable_attributes).to include('ref_domain')
    end
  end

  describe '.ransackable_associations' do
    it 'includes events association' do
      expect(Ahoy::Visit.ransackable_associations).to include('events')
    end
  end
end
