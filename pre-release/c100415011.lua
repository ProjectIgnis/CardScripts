--聖なる法典
--Magistus Invocation
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=s.mfilter,extrafil=s.fextra})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x24b}
function s.mfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToGrave())
		or (c:IsOriginalType(TYPE_MONSTER) and c:IsLocation(LOCATION_SZONE) and c:IsType(TYPE_EQUIP) and c:GetEquipTarget():IsSetCard(0x24b))
end
function s.checkmat(tp,sg,fc)
	return (fc:IsSetCard(0x24b) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE)) and sg:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil),s.checkmat
end
