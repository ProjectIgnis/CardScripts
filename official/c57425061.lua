--幻影融合
--Vision Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x8),nil,s.fextra)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x8}
function s.exfilter0(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and c:GetType()&(TYPE_TRAP+TYPE_CONTINUOUS)==TYPE_TRAP+TYPE_CONTINUOUS
		and c:IsAbleToRemove()
end
function s.matlimit(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsLocation(LOCATION_SZONE)
		and c:GetType()&(TYPE_TRAP+TYPE_CONTINUOUS)==TYPE_TRAP+TYPE_CONTINUOUS
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(s.matlimit,nil)<=2
end
function s.fextra(e,tp,mg)
	local sg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_SZONE,0,nil)
	if #sg>0 then
		return sg,s.fcheck
	end
	return nil
end
