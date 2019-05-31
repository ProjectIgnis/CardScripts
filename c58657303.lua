--墓守の霊術師
--Gravekeeper's Spiritualist
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	local params = {aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),nil,nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NECROVALLEY}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(CARD_NECROVALLEY)
end
