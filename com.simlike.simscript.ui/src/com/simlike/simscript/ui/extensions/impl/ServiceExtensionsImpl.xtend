package com.simlike.simscript.ui.extensions.impl

import com.google.inject.Inject
import com.google.inject.Singleton
import com.simlike.simscript.backend.simBackendDsl.Interface
import com.simlike.simscript.backend.simBackendDsl.LegacyServlet
import com.simlike.simscript.structure.structureDsl.BuiltinTypes
import com.simlike.simscript.structure.structureDsl.TypeLiteral
import com.simlike.simscript.structure.types.TypeExtensions
import com.simlike.simscript.ui.extensions.ServiceExtensions
import com.simlike.simscript.ui.simUiDsl.CrudServiceIdentification
import com.simlike.simscript.ui.simUiDsl.CrudTypes
import com.simlike.simscript.ui.simUiDsl.NamedServiceReference
import com.simlike.simscript.ui.simUiDsl.ServiceIdentification

@Singleton
class ServiceExtensionsImpl implements ServiceExtensions {

	@Inject extension TypeExtensions


	override TypeLiteral inputType(ServiceIdentification it) {
		inputType_
	}

	def private dispatch TypeLiteral inputType_(NamedServiceReference it) {
		switch service {
			Interface:		service.inputType
			LegacyServlet:	null
		}
	}

	def private dispatch TypeLiteral inputType_(CrudServiceIdentification it) {
		switch crudType {
			case CrudTypes::CREATE: 	structure.createDefinedTypeLiteral
			case CrudTypes::UPDATE: 	structure.createDefinedTypeLiteral
			case CrudTypes::DELETE: 	structure.createDefinedTypeLiteral
			case CrudTypes::GET_BY_ID:	BuiltinTypes::INTEGER.createBuiltinTypeLiteral
		}
	}


	override returnType(ServiceIdentification it) {
		returnType_
	}

	def private dispatch returnType_(NamedServiceReference it) {
		switch service {
			Interface:		service.outputType
			LegacyServlet:	null	// uncomputable type
		}
	}

	def private dispatch returnType_(CrudServiceIdentification it) {
		switch crudType {
			case CrudTypes::CREATE:		createVoidLiteral
			case CrudTypes::DELETE:		createVoidLiteral
			case CrudTypes::GET_BY_ID:	structure.createDefinedTypeLiteral
			case CrudTypes::UPDATE:		createVoidLiteral
		}
	}


	override isInterface(ServiceIdentification it) {
		it instanceof NamedServiceReference && (it as NamedServiceReference).service instanceof Interface
	}

	override isLegacyServlet(ServiceIdentification it) {
		it instanceof NamedServiceReference && (it as NamedServiceReference).service instanceof LegacyServlet
	}

}
