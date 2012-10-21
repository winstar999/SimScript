package com.simlike.simscript.backend.validation

import com.google.inject.Inject
import com.google.inject.Singleton
import com.simlike.simscript.backend.SimBackendDslExtensions
import com.simlike.simscript.backend.simBackendDsl.BackendModel
import com.simlike.simscript.backend.simBackendDsl.Interface
import com.simlike.simscript.backend.simBackendDsl.LegacyServlet
import com.simlike.simscript.backend.simBackendDsl.NamedService
import com.simlike.simscript.backend.simBackendDsl.SimBackendDslPackage
import com.simlike.simscript.util.XtextUtil
import org.eclipse.xtext.validation.Check

@Singleton
class SimBackendDslXtendValidator extends AbstractSimBackendDslJavaValidator {

	@Inject extension XtextUtil

	@Inject extension SimBackendDslExtensions

	private SimBackendDslPackage ePackage = SimBackendDslPackage::eINSTANCE

	@Check
	def void check_baseURL_ends_in_trailing_slash(BackendModel it) {
		if( !baseUrl.nullOrEmpty && !baseUrl.endsWith("/") ) {
			error("baseURL must end on trailing slash", ePackage.backendModel_BaseUrl)
		}
	}

	@Check
	def check_service_name_starts_with_lower_capital(NamedService it) {
		if( !uncapitalized ) {
			warning( "the name of a service (interface) should start with a lower case character", ePackage.namedService_Name )
		}
	}

	def private isUncapitalized(NamedService it) {
		Character::isLowerCase(name.charAt(0))
	}

	@Check
	def warn_legacy_servlets_are_deprecated(LegacyServlet it) {
		warning("legacy servlets (definitions) are deprecated and should be replaced by (regular) interface (definitions)", this)
	}

	@Check
	def check_output_type_of_interface(Interface it) {
		if( outputType != null && !outputType.correctlyTypedOutput ) {
			error("output type of an interface must be a structure or a list of structures", ePackage.interface_OutputType)
		}
	}

	@Check
	def check_non_sensical_definition(Interface it) {
		if( inputType == null && outputType == null ) {
			error("interface must have either an input, an output or both", this)
		}
	}

}
