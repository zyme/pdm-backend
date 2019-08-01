class FhirUtilities
	def initialize
    	@fhir = FHIR::DSTU2 # or FHIR
    	@fhir_string = "FHIR::DSTU2" # or "FHIR"
	end

	def get_fhir
		@fhir
	end

	def get_fhir_string
		@fhir_string
	end
end
