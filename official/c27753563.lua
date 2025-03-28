--運命のウラドラ
--Uradora of Fate
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(Cost.PayLP(1000))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		--Reveal the bottom card of your Deck
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.drcon)
		e2:SetTarget(s.drtg)
		e2:SetOperation(s.drop)
		e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
		Duel.RegisterEffect(e2,tp)
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN&~(RESET_LEAVE|RESET_TODECK|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE),0,1)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE) and tc:GetFlagEffect(id)>0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.IsPlayerCanDraw(tp) end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #g==0 then return end
	local tc=g:GetMinGroup(Card.GetSequence):GetFirst()
	Duel.ConfirmCards(tp,tc)
	Duel.ConfirmCards(1-tp,tc)
	local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	if op==0 then Duel.MoveSequence(tc,0) end
	if not (tc:IsRace(RACE_DRAGON|RACE_DINOSAUR|RACE_SEASERPENT|RACE_WYRM) and tc:IsAttackAbove(1000)) then return end
	local ct=Duel.Draw(tp,math.floor(tc:GetAttack()/1000),REASON_EFFECT)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Recover(tp,ct*1000,REASON_EFFECT)
	end
end