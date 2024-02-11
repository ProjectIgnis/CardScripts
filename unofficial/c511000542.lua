--クロス・シフト
--Cross Shift
local s,id=GetID()
function s.initial_effect(c)
	--Swap 1 monster on the field with a monster in your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsLevelBelow(4) and c:IsMonster() and not c:IsForbidden()
end
function s.thfilter(c)
	return c:IsAbleToHand() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g1>0 and #g2>0 then
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.MoveToField(g1:GetFirst(),tp,tp,LOCATION_MZONE,POS_FACEUP|POS_FACEDOWN,true)
	end
end