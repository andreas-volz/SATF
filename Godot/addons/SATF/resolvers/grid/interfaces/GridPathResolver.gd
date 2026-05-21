class_name GridPathResolver
extends RefCounted

## GridPathResolver
##
## Defines the contract for resolving texture/asset paths from a
## GridSpriteComposition context.
##
## A GridPathResolver does NOT store state and does NOT modify the
## composition. It only interprets the given data and returns a final
## resolved path as StringName.
##
## Different implementations (e.g. SimpleGridPathResolver, LPCGridPathResolver)
## define different rule sets for how paths are constructed (e.g. fallback rules,
## custom animations, folder remapping).
##
## The resolver is injected into a GridSpriteStrategy (or similar orchestrator)
## via a GridResolverContext and is used during SATF normalization.
##
## This design allows swapping path resolution logic without changing the
## core SATF pipeline or data structures.

func resolve(layer_data: GridLayerData, animation_name: StringName) -> OptionalString:
	# empty implementation, only interface definition
	return null
