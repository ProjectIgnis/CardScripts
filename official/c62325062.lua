--粘着落とし穴
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:GetSummonPlayer()~=tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) end
	Duel.SetTargetCard(eg)
end
function s.filter2(c,e,tp)
	return c:IsFaceup() and not c:IsSummonPlayer(tp) and c:IsRelateToEffect(e) 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter2,nil,e,tp)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.atkval(e,c)
	return c:GetBaseAttack()/2
end
