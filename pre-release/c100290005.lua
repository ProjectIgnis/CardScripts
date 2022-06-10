--ダイス・ダンジョン
--Dice Dungeon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--At the start of the Battle Phase, roll die and apply effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.dicetg)
	e2:SetOperation(s.diceop)
	c:RegisterEffect(e2)
end
s.roll_dice=true
s.listed_names={100290006} --Dimension Dice's ID, to be replaced by the official ID later
function s.thfilter(c)
	return c:IsCode(100290006) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--Note: scripted as if the effect applies only to monsters the players current control
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,1,PLAYER_ALL,0)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local turn_p=Duel.GetTurnPlayer()
	local res1=Duel.TossDice(turn_p,1)
	local res2=Duel.TossDice(1-turn_p,1)
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g1==0 and #g2==0 then return end
	local c=e:GetHandler()
	if #g1>0 then
		g1:ForEach(s.atkchange,res1,c)
	end
	if #g2>0 then
		g2:ForEach(s.atkchange,res2,c)
	end
end
function s.atkchange(tc,opt,c)
	if opt==5 or opt==6 then --for double or half ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		if opt==5 then
			e1:SetValue(tc:GetAttack()/2) --5: halve the current aTK
		else
			e1:SetValue(tc:GetAttack()*2) --6: double the current aTK
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else  --for other atk increase/decrease
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		if opt==1 then
			e1:SetValue(-1000) --1: lose 1000 ATK
		elseif opt==2 then
			e1:SetValue(1000) --2: gain 1000 ATK
		elseif opt==3 then
			e1:SetValue(-500) --3: lose 500 ATK
		elseif opt==4 then
			e1:SetValue(500) --4: gain 500 ATK
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end