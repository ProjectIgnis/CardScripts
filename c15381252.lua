--狂戦士の魂
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():GetControler()==tp and ev<=1500 and Duel.GetAttackTarget()==nil
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return #g>0 and g:FilterCount(Card.IsDiscardable,nil)==#g
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local count=8
	while count>0 and Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetLP(1-tp)>0 do
		if count<8 then Duel.BreakEffect() end
		Duel.ConfirmDecktop(tp,1)
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			Duel.DisableShuffleCheck()
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
			if tc:IsLocation(LOCATION_GRAVE) then
				Duel.Damage(1-tp,500,REASON_EFFECT)
				count=count-1
			else count=0 end
		else
			count=0
		end
	end
end
