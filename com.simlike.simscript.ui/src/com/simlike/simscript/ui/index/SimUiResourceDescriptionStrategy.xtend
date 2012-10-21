package com.simlike.simscript.ui.index

import com.google.inject.Inject
import com.google.inject.Singleton
import com.simlike.simscript.ui.extensions.StructuralExtensions
import com.simlike.simscript.ui.simUiDsl.MethodDefinition
import com.simlike.simscript.ui.simUiDsl.TableRowsDefinition
import com.simlike.simscript.ui.simUiDsl.UiModule
import com.simlike.simscript.ui.simUiDsl.Viewable
import com.simlike.simscript.util.XtextUtil
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IReferenceDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor

@Singleton
class SimUiResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	@Inject extension StructuralExtensions

	@Inject extension XtextUtil


	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		createEObjectDescriptions_(eObject, acceptor)	// dispatch
	}

	def private dispatch createEObjectDescriptions_(UiModule it, IAcceptor<IEObjectDescription> acceptor) {
		exportName(name, acceptor)
		true
	}

	def private dispatch createEObjectDescriptions_(Viewable it, IAcceptor<IEObjectDescription> acceptor) {
		exportName(name, acceptor)
		false
	}

	def private dispatch createEObjectDescriptions_(TableRowsDefinition it, IAcceptor<IEObjectDescription> acceptor) {
		false
	}

	def private dispatch createEObjectDescriptions_(MethodDefinition it, IAcceptor<IEObjectDescription> acceptor) {
		false
	}
	// TODO  export all top-level methods and rely on Index for correct scoping

	override createReferenceDescriptions(EObject from, URI exportedContainerURI, IAcceptor<IReferenceDescription> acceptor) {
		false
	}

}
