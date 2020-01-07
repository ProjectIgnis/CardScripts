--D - Hyper Nova
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsStatus,tp,0,LOCATION_MZONE,1,nil,STATUS_SPSUMMON_TURN) end
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	Duel.Destroy(g,REASON_EFFECT)
end
