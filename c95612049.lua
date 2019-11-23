--リバース・オブ・ザ・ワールド
--Turning of the World
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsCode,46427957,72426662),nil,nil,nil,nil,s.mfilter,nil,LOCATION_HAND+LOCATION_DECK)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_names={72426662}
function s.mfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsType(TYPE_RITUAL)
end

