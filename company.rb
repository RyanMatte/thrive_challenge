class Company
    attr_reader :name, :id, :email_status, :top_up

    def initialize(company)
        @id = company["id"] || null
        @name = company["name"]
        @email_status = company["email_status"]
        @top_up = company["top_up"]
    end
end
