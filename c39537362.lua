--旅人の試練
--Ordeal of a Traveler
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and tp~=Duel.GetTurnPlayer()
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then 
		e:SetLabel(1)
		Duel.SetTargetCard(Duel.GetAttacker())
		e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	else e:SetLabel(0) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	Duel.SetTargetCard(Duel.GetAttacker())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1 or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		or not e:GetHandler():IsRelateToEffect(e) or not Duel.GetAttacker():IsRelateToEffect(e)	then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):RandomSelect(1-tp,1,nil)
	local tc=g:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(1-tp,70,71,72)
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	if (op~=0 and tc:IsType(TYPE_MONSTER)) or (op~=1 and tc:IsType(TYPE_SPELL)) or (op~=2 and tc:IsType(TYPE_TRAP)) then
		Duel.SendtoHand(Duel.GetAttacker(),nil,REASON_EFFECT)
	end
end
