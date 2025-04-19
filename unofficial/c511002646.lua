--地獄蟲地雷
--Hell Vermin Mine
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsHell() and c:IsMonster() and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) 
		and Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil) 
	local dg=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if g1:GetFirst() and g2:GetFirst() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g2:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		Duel.SendtoGrave(tg,REASON_EFFECT)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end