--見えざる招き手
--Yad'al-Hecahands
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Negate the activation of an opponent's Spell/Trap Card, and if you do, destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HECAHANDS}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==1-tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_HECAHANDS),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
		if rc:IsLocation(LOCATION_GRAVE) then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,rc,1,tp,0)
		end
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 and not rc:IsLocation(LOCATION_HAND|LOCATION_DECK)
		and aux.nvfilter(rc) and rc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.SSet(tp,rc)
	end
end