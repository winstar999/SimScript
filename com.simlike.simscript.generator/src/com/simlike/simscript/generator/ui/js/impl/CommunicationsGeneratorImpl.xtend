package com.simlike.simscript.generator.ui.js.impl

import com.google.inject.Inject
import com.google.inject.Singleton
import com.simlike.simscript.backend.SimBackendDslExtensions
import com.simlike.simscript.backend.simBackendDsl.Interface
import com.simlike.simscript.generator.ui.js.CommunicationsGenerator
import com.simlike.simscript.structure.structureDsl.Structure
import com.simlike.simscript.structure.types.TypeExtensions
import com.simlike.simscript.ui.simUiDsl.CrudServiceIdentification
import com.simlike.simscript.ui.simUiDsl.CrudTypes
import com.simlike.simscript.ui.simUiDsl.InterfaceCallExpression
import com.simlike.simscript.ui.simUiDsl.NamedServiceReference
import com.simlike.simscript.ui.simUiDsl.UiModule
import java.util.Set
import org.eclipse.xtext.EcoreUtil2

import static com.simlike.simscript.generator.ui.js.CommunicationsGenerator.*

@Singleton
class CommunicationsGeneratorImpl implements CommunicationsGenerator {

	@Inject extension SimBackendDslExtensions
	@Inject extension TypeExtensions

	override interfaceFunctions(UiModule it)
		'''
		«FOR interface_ : referredInterfaces»
			«interface_.function»

		«ENDFOR»
		«FOR crud : referredCruds»
			«crud.function»

		«ENDFOR»
		'''

	/**
	 * Dependencies/Assumptions:
	 * 1.)	This method's generated function is called by the code generated from asJs(InterfaceCallStatement it).
	 * 	This means that any changes in the generated function's call signature should be update there as well.
	 * 2.)	The signature of the callbacks supplied to this method's generated function are generated by 
	 * 	asJs(InterfaceCallStatement it). If (the order of) the arguments supplied to these callbacks changes,
	 * 	this should be updated in the asJs method as well.
	 * 3.)	Authentication is always a required and wrapped argument. Passing null or undefined is allowed.
	 * 
	 * TODO:
	 * 1.)	Generalize the url?
	 */
	def private function(Interface it)
		'''
		// interface «name»:
		function «name»(«IF inputType != null»input, «ENDIF»auth, callback, errCallback) {
			var data = {«IF !notAuthenticated»authenticationInfo : auth.unwrap()«ENDIF»};
			«IF inputType != null»data = $.extend(data, { '«inputType.structure.name.toFirstLower»' : ItemSerializer.serialize(input) });«ENDIF»
			$.ajax({
				url: '«baseUrl»«url»«suffix»',
				data: data,
				dataType:'json',
				type:'«method»',
				cache: false,
				success: function(aObj) {
					var a = new Item(aObj);
					«IF outputType != null»
						«IF outputType.structureTyped»
							a = new Item(«outputType.structure.name»ToFullItemFunction(aObj));
							«outputType.structure.name»DateParseFunction(a);
						«ELSEIF outputType.listTyped && outputType.listItemType.structureTyped»
							if (aObj.length > 0) {
								var aList = [];
								for (var i = 0; i < aObj.length; i++) {
									aList.push(«outputType.listItemType.structure.name»ToFullItemFunction(aObj[i]));
								}
								a = new Item(aList);
								a.forAll(«outputType.listItemType.structure.name»DateParseFunction);
							}
						«ENDIF»
					«ENDIF»
					callback(a);
				},
				error : function() { if(arguments[2]) { errCallback(null, new Item(arguments[2])); } else { errCallback(null, new Item('Unknown Failure!')); } }
			});
		}
		'''


	/**
	 * Dependencies/Assumptions:
	 * 1.)	The path to the servlet should be the same as the one generated in the WebXmlGenerator
	 * 2.)	Assumes all crudservices take input and auth
	 * 3.)	The servlets expect the given data to be under the json key 'data'
	 * 4.)	Assumes only get-by-id crudservice has an output
	 * 
	 * TODO create a function to check if a CRUD service has an output
	 */
	def private function(CrudServiceIdentification it) 
		'''
		// interface «crudType.literal»«structure.name»:
		function «crudType.literal»«structure.name»(input, auth, callback, errCallback) {
			var data = $.extend({}, auth.unwrap());
			data['«structure.name.toFirstLower»'] = ItemSerializer.serialize(input);
			$.ajax({
				url: '«defaultApiBaseUrl»«crudType.literal»«structure.name»',
				data: data,
				dataType: 'json',
				type: 'POST',
				cache: false,
				success: function(aObj) {
					var a = new Item(aObj);
					«IF crudType == CrudTypes::GET_BY_ID»
						a = new Item(«structure.name»ToFullItemFunction(aObj));
						«structure.name»DateParseFunction(a);
					«ENDIF»
					callback(a);
				},
				error: function() { if(arguments[2]) { errCallback(null, new Item(arguments[2])); } else { errCallback(null, new Item('Unknown Failure!')); } }
			});
		}
		'''

	def private referredInterfaces(UiModule it) {
		referredServiceIdentifications.filter(typeof(NamedServiceReference)).map[service].filter(typeof(Interface)).toSet
	}

	def private referredCruds(UiModule it) {
		referredServiceIdentifications.filter(typeof(CrudServiceIdentification)).toSet
	}

	def private referredServiceIdentifications(UiModule it) {
		val calls = EcoreUtil2::eAllOfType(it, typeof(InterfaceCallExpression))
		calls.map[serviceId]
	}

	def private extendWithContainedStructures(Structure it, Set<Structure> set) {
		if (set.add(it)) {
			for (s : structureTypedFeatures.map[type.structure]) {
				s.extendWithContainedStructures(set)
			}
			for (s : listTypedFeatures.map[type.listItemType].filter[structureTyped].map[structure]) {
				s.extendWithContainedStructures(set)
			}
		}
	}

}
