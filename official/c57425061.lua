--幻影融合
--Vision Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_HERO),nil,s.fextra,s.extraop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HERO}
function s.exfilter0(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
		and c:IsContinuousTrap() and c:IsAbleToRemove()
end
function s.matlimit(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsLocation(LOCATION_SZONE) and c:IsContinuousTrap()
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
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_SZONE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end