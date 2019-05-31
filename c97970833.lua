--ラスト・リゾート
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={34487429}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c,tp)
	return c:IsCode(34487429) and c:GetActivateEffect():IsActivatable(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_DECK,0,nil,tp)
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc and fc:IsFaceup() and Duel.IsPlayerCanDraw(1-tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Draw(1-tp,1,REASON_EFFECT)
		end
		Duel.RaiseEvent(tc,4179255,tc:GetActivateEffect(),0,tp,tp,Duel.GetCurrentChain())
	end
end
