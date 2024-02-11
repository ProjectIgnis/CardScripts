--ラス・オブ・アビス
--Wrath of Abyss
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) and c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(s.cfilter,tp,LOCATION_MZONE,0,nil)>=2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return ep==1-tp and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) end
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		if not Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,1,nil) and #g>0 then
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
