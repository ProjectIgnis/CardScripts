--伝説の賭博師
--Gambler of Legend
local s,id=GetID()
function s.initial_effect(c)
	--Toss 3 coins and apply the appropriate effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c1,c2,c3=Duel.TossCoin(tp,3)
	local total_heads=Duel.CountHeads(c1,c2,c3)
	if total_heads==3 then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
	elseif total_heads==2 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	elseif total_heads==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT)
	elseif Duel.CountTails(c1,c2,c3)==3 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end