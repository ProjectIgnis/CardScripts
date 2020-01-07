--Secret Mission
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
	return tp~=Duel.GetTurnPlayer()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local opt=0
	if Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(15552258,1))
	else
		opt=Duel.SelectOption(1-tp,aux.Stringid(15552258,1))+1
	end
	if opt==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		local sg=g:RandomSelect(1-tp,1)
		Duel.SetTargetCard(sg)
	end
	e:SetLabel(opt)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==1 then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
		return
	end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.CalculateDamage(Duel.GetAttacker(),tc)
	end
end
