--チェンジ・デステニー
--Changing Destiny
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsLocation(LOCATION_MZONE) and tc:IsAttackPos()
		and tc:IsCanChangePosition() and tc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToEffect(e) and Duel.NegateAttack() and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		--Cannot change its battle position
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3313)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local val=tc:GetAttack()/2
		local op=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
		if op==0 then Duel.Recover(1-tp,val,REASON_EFFECT)
		else Duel.Damage(tp,val,REASON_EFFECT) end
	end
end