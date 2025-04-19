if not load then
	return
end
local function make_deprecated_function_alias(old_funcname,new_funcname)
	load(old_funcname .. [[= function(...)
		Debug.PrintStacktrace()
		Debug.Message("]] .. old_funcname .. [[ is deprecated, use ]] .. new_funcname .. [[ instead.")
		return load("return ]] .. new_funcname .. [[(...)")(...)
	end]],"make_deprecated_function_alias")()
end

local function make_deleted_replaced_function(old_funcname,new_funcname)
	load(old_funcname .. [[= function()
		error("]].. old_funcname ..[[ was deleted. Use ]] .. new_funcname .. [[ instead.",2)
	end]])()
end

--Functions deprecated since version 40.0 and deleted in 41.0:
make_deleted_replaced_function("Auxiliary.AskAny","Duel.AskAny")
make_deleted_replaced_function("Auxiliary.AskEveryone","Duel.AskEveryone")
make_deleted_replaced_function("Auxiliary.AnnounceAnotherAttribute","Duel.AnnounceAnotherAttribute")
make_deleted_replaced_function("Auxiliary.AnnounceAnotherRace","Duel.AnnounceAnotherRace")
make_deleted_replaced_function("Auxiliary.SelectEffect","Duel.SelectEffect")
make_deleted_replaced_function("Auxiliary.PlayFieldSpell","Duel.ActivateFieldSpell")
make_deleted_replaced_function("Auxiliary.CheckPendulumZones","Duel.CheckPendulumZones")
make_deleted_replaced_function("Auxiliary.nzatk","Card.HasNonZeroAttack")
make_deleted_replaced_function("Auxiliary.nzdef","Card.HasNonZeroDefense")
make_deleted_replaced_function("Auxiliary.disfilter1","Card.IsNegatableMonster")
make_deleted_replaced_function("Auxiliary.disfilter2","Card.IsNegatableSpellTrap")
make_deleted_replaced_function("Auxiliary.disfilter3","Card.IsNegatable")
make_deleted_replaced_function("Auxiliary.HasCounterListed","Card.ListsCounter")
make_deleted_replaced_function("Auxiliary.CanPlaceCounter","Card.PlacesCounter")
make_deleted_replaced_function("Auxiliary.EquipByEffectLimit","Card.EquipByEffectLimit")
make_deleted_replaced_function("Auxiliary.EquipByEffectAndLimitRegister","Card.EquipByEffectAndLimitRegister")
make_deleted_replaced_function("Auxiliary.IsMaterialListCode","Card.ListsCodeAsMaterial")
make_deleted_replaced_function("Auxiliary.IsMaterialListSetCard","Card.ListsArchetypeAsMaterial")
make_deleted_replaced_function("Auxiliary.IsArchetypeCodeListed","Card.ListsCodeWithArchetype")
make_deleted_replaced_function("Auxiliary.IsCodeListed","Card.ListsCode")
make_deleted_replaced_function("Auxiliary.IsCardTypeListed","Card.ListsCardType")
make_deleted_replaced_function("Auxiliary.HasListedSetCode","Card.ListsArchetype")
make_deleted_replaced_function("Auxiliary.IsGeminiState","Gemini.EffectStatusCondition")
make_deleted_replaced_function("Auxiliary.IsNotGeminiState","Auxiliary.NOT(Gemini.EffectStatusCondition)")
make_deleted_replaced_function("Auxiliary.GeminiNormalCondition","Gemini.NormalStatusCondition")
make_deleted_replaced_function("Auxiliary.EnableGeminiAttribute","Gemini.AddProcedure")
make_deleted_replaced_function("Auxiliary.EnableSpiritReturn","Spirit.AddProcedure")
make_deleted_replaced_function("Auxiliary.SpiritReturnReg","Spirit.SummonRegister")
make_deleted_replaced_function("Auxiliary.SpiritReturnOperation","Spirit.ReturnOperation")
make_deleted_replaced_function("Auxiliary.FilterFaceupFunction","Auxiliary.FaceupFilter")
make_deleted_replaced_function("Auxiliary.MZFilter","Card.IsInMainMZone")
make_deleted_replaced_function("Card.IsDifferentAttribute","Card.IsAttributeExcept")

local function make_deleted_function(funcname,message)
	load(funcname .. [[= function()
		error("]].. funcname ..[[ was deleted. ]] .. message .. [[",2)
	end]])()
end
--Deleted functions
make_deleted_function("Auxiliary.CallToken","Use Duel.LoadCardScript or Duel.LoadScript instead.")
make_deleted_function("Auxiliary.SpiritReturnCondition","Check Spirit.MandatoryReturnCondition and Spirit.OptionalReturnCondition for more details.")
make_deleted_function("Auxiliary.SpiritReturnTarget","Check Spirit.MandatoryReturnTarget and Spirit.OptionalReturnTarget for more details.")
