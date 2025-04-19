--ディープワーニング・フュージョン
--Deep Warning Fusion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.ffilter,matfilter=s.mfilter,extrafil=s.fextra,stage2=s.stage2})
	e1:SetDescription(aux.Stringid(id,0))
	c:RegisterEffect(e1)
end
s.listed_names={160211009}
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE)
end
function s.mfilter(c)
	if c:IsLocation(LOCATION_MZONE) then return c:IsFaceup() and c:IsAbleToGrave() end
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToGrave()
end
function s.checkmat(tp,sg,fc)
	return sg:GetClassCount(Card.GetLocation)==1
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil),s.checkmat
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsOriginalCodeRule(160211009)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		local mg=tc:GetMaterial()
		local ct=mg:FilterCount(s.cfilter,nil)
		if ct>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.HintSelection(g,true)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end