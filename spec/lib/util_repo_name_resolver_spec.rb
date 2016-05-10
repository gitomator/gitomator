require 'gitomator/util/repo/name_resolver'
require 'securerandom'

describe Gitomator::Util::Repo::NameResolver do

  context 'With a default namespace' do

    let(:default_namespace) { SecureRandom.hex }
    let(:name_resolver) { Gitomator::Util::Repo::NameResolver.new(default_namespace) }

    describe "#tokenize" do

      it "handles repo-name only" do
        name = SecureRandom.hex
        tokenized = name_resolver.tokenize(name)
        expect(tokenized).to eq [default_namespace, name, nil]
      end


      it "handles namespace and repo-name" do
        namespace = SecureRandom.hex
        name = SecureRandom.hex
        tokenized = name_resolver.tokenize("#{namespace}/#{name}")
        expect(tokenized).to eq [namespace, name, nil]
      end

      it "handles namespace, repo-name and branch" do
        namespace = SecureRandom.hex
        name = SecureRandom.hex
        branch = SecureRandom.hex
        tokenized = name_resolver.tokenize("#{namespace}/#{name}:#{branch}")
        expect(tokenized).to eq [namespace, name, branch]
      end

      it "fails when the name has more than two components" do
        expect { name_resolver.tokenize("a/b/c") }.to raise_error(StandardError)
      end

      it "fails on empty string" do
        expect { name_resolver.tokenize("") }.to raise_error(StandardError)
      end

    end


    describe "#full_name" do

      it "handles names with missing namespace" do
        name = SecureRandom.hex
        expect(name_resolver.full_name(name)).to eq "#{default_namespace}/#{name}"
      end


      it "handles names with namespace" do
        namespace = SecureRandom.hex
        name = SecureRandom.hex
        expect(name_resolver.full_name("#{namespace}/#{name}")).to eq "#{namespace}/#{name}"
      end

      it "fails when the name has more than two components" do
        expect { name_resolver.full_name("a/b/c") }.to raise_error(StandardError)
      end

    end


    describe "#namespace" do

      it "handles names with missing namespace" do
        name = SecureRandom.hex
        expect(name_resolver.namespace(name)).to eq default_namespace
      end


      it "handles names with namespace" do
        namespace = SecureRandom.hex
        name = SecureRandom.hex
        expect(name_resolver.namespace("#{namespace}/#{name}")).to eq namespace
      end

      it "fails when the name has more than two components" do
        expect { name_resolver.namespace("a/b/c") }.to raise_error(StandardError)
      end

    end


    describe "#name_only" do

      it "handles names with missing namespace" do
        name = SecureRandom.hex
        expect(name_resolver.name_only(name)).to eq name
      end


      it "handles names with namespace" do
        namespace = SecureRandom.hex
        name = SecureRandom.hex
        expect(name_resolver.name_only("#{namespace}/#{name}")).to eq name
      end

      it "fails when the name has more than two components" do
        expect { name_resolver.name_only("a/b/c") }.to raise_error(StandardError)
      end

    end



  end





  context 'Without a default namespace' do

    let(:name_resolver) { Gitomator::Util::Repo::NameResolver.new() }



        describe "#tokenize" do

          it "handles repo-name only" do
            name = SecureRandom.hex
            tokenized = name_resolver.tokenize(name)
            expect(tokenized).to eq [nil, name, nil]
          end

          it "handles namespace and repo-name" do
            namespace = SecureRandom.hex
            name = SecureRandom.hex
            tokenized = name_resolver.tokenize("#{namespace}/#{name}")
            expect(tokenized).to eq [namespace, name, nil]
          end

          it "handles namespace, repo-name and branch" do
            namespace = SecureRandom.hex
            name = SecureRandom.hex
            branch = SecureRandom.hex
            tokenized = name_resolver.tokenize("#{namespace}/#{name}:#{branch}")
            expect(tokenized).to eq [namespace, name, branch]
          end

          it "fails when the name has more than two components" do
            expect { name_resolver.tokenize("a/b/c") }.to raise_error(StandardError)
          end

          it "fails on empty string" do
            expect { name_resolver.tokenize("") }.to raise_error(StandardError)
          end

        end


        describe "#full_name" do

          it "handles names with missing namespace" do
            name = SecureRandom.hex
            expect(name_resolver.full_name(name)).to eq name
          end


          it "handles names with namespace" do
            namespace = SecureRandom.hex
            name = SecureRandom.hex
            expect(name_resolver.full_name("#{namespace}/#{name}")).to eq "#{namespace}/#{name}"
          end

          it "fails when the name has more than two components" do
            expect { name_resolver.full_name("a/b/c") }.to raise_error(StandardError)
          end

        end


        describe "#namespace" do

          it "handles names with missing namespace" do
            name = SecureRandom.hex
            expect(name_resolver.namespace(name)).to be_nil
          end


          it "handles names with namespace" do
            namespace = SecureRandom.hex
            name = SecureRandom.hex
            expect(name_resolver.namespace("#{namespace}/#{name}")).to eq namespace
          end

          it "fails when the name has more than two components" do
            expect { name_resolver.namespace("a/b/c") }.to raise_error(StandardError)
          end

        end


        describe "#name_only" do

          it "handles names with missing namespace" do
            name = SecureRandom.hex
            expect(name_resolver.name_only(name)).to eq name
          end


          it "handles names with namespace" do
            namespace = SecureRandom.hex
            name = SecureRandom.hex
            expect(name_resolver.name_only("#{namespace}/#{name}")).to eq name
          end

          it "fails when the name has more than two components" do
            expect { name_resolver.name_only("a/b/c") }.to raise_error(StandardError)
          end

        end


  end

end
