package nl.dslmeinte.simscript.generator.ui.js.impl

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.Set
import nl.dslmeinte.simscript.backend.simBackendDsl.Interface
import nl.dslmeinte.simscript.backend.simBackendDsl.Service
import nl.dslmeinte.simscript.extensions.BackendExtensions
import nl.dslmeinte.simscript.generator.ui.js.CommunicationsGenerator
import nl.dslmeinte.simscript.structure.structureDsl.Structure
import nl.dslmeinte.simscript.types.TypeExtensions
import nl.dslmeinte.simscript.ui.simUiDsl.CrudServiceIdentification
import nl.dslmeinte.simscript.ui.simUiDsl.CrudTypes
import nl.dslmeinte.simscript.ui.simUiDsl.InterfaceCallExpression
import nl.dslmeinte.simscript.ui.simUiDsl.NamedServiceReference
import nl.dslmeinte.simscript.ui.simUiDsl.UiModule
import org.eclipse.xtext.EcoreUtil2

@Singleton
class CommunicationsGeneratorImpl implements CommunicationsGenerator {

	@Inject extension BackendExtensions
	@Inject extension TypeExtensions

	override interfaceFunctions(UiModule it)
		'''
		«FOR interface_ : referredInterfaces»
			«interface_.function(true)»

		«ENDFOR»
		«FOR crud : referredCruds»
			«crud.function(true)»

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
	def private function(Interface it, boolean withName)
		'''
		// interface «name»:
		function «IF withName»«name»«ENDIF»(«IF inputType != null»input, «ENDIF»auth, callback, errCallback) {
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
	def private function(CrudServiceIdentification it, boolean withName) 
		'''
		// interface «crudType.literal»«structure.name»:
		function «IF withName»«crudType.literal»«structure.name»«ENDIF»(input, auth, callback, errCallback) {
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
					«IF crudType == CrudTypes.GET_BY_ID»
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
		val calls = EcoreUtil2.eAllOfType(it, typeof(InterfaceCallExpression))
		calls.map[serviceId]
	}

	def private void extendWithContainedStructures(Structure it, Set<Structure> set) {
		if (set.add(it)) {
			for (s : structureTypedFeatures.map[type.structure]) {
				s.extendWithContainedStructures(set)
			}
			for (s : listTypedFeatures.map[type.listItemType].filter[structureTyped].map[structure]) {
				s.extendWithContainedStructures(set)
			}
		}
	}


	override generateDeclarations(Iterable<Service> services) {
		'''
		var API = {};
		// callback(exactResponse)
		// errCallback(errorString)
		API.authenticate = function (input, callback, errCallback) {
			$.ajax({
				url : 'https://fb.DSLConsultancy.com/api/authenticate',
				data : {authenticationInfo:input},
				dataType : 'json',
				type : 'POST',
				cache : false,
				success : callback,
				error : function() {
					if(arguments[2]) {
						errCallback(arguments[2]);
					} else {
						errCallback('Unknown Failure!');
					}
				}
			});
		};
			«FOR it : services.filter(typeof(Interface))»
				API.«name» =
					«it.function(false)»
				;

			«ENDFOR»
			«FOR it : services.filter(typeof(CrudServiceIdentification))»
				API.«crudType.literal»«structure.name» =
					«it.function(false)»
				;
			«ENDFOR»
		'''
	}
}
