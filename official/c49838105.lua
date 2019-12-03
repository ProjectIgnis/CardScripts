--森羅の滝滑り
--Sylvan Waterslide
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	--draw replacement
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.cfcon)
	e3:SetCost(s.cfcost)
	e3:SetTarget(s.cftg)
	e3:SetOperation(s.cfop)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	else
		Duel.MoveSequence(tc,1)
	end
end
function s.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.GiveUpDraw(e)
end
function s.cfcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetDrawCount(tp)>0
end
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	_replace_count=_replace_count+1
	if Duel.CheckGiveUpDraw(e) and _replace_count<=_replace_max and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
		Duel.ConfirmDecktop(tp,1)
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		Duel.DisableShuffleCheck()
		if tc:IsRace(RACE_PLANT) then
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ShuffleHand(tp)
		end
	end
end
