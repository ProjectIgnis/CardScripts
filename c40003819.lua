--転臨の守護竜
--Guardragon Reincarnation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat(aux.FilterBoolFunction(Card.IsType,TYPE_LINK),Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.FilterBoolFunction(Card.IsType,TYPE_LINK),Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
