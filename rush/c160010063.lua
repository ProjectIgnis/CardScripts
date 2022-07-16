--ゲッコーの３不思議
--The Three Moonlit Mystery Geckos
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_NORMAL) and c:IsLevel(3) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE,0,1,nil) then
		local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsRace,RACE_REPTILE),tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 and ct>0 then
			Duel.HintSelection(g,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffectRush(e1)
		end
	end
end