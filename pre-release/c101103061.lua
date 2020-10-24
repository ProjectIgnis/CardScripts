--混錬装融合
--Parametalfoes Fusion
--Scripted by edo9300

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xe1),extrafil=s.extrafil})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0xe1}
function s.check(tp,sg,fc)
	return sg:GetClassCount(function(c) return c:GetLocation()&~(LOCATION_ONFIELD) end)==#sg
end
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_EXTRA,0,nil),s.check
end
