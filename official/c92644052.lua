--ＥＭ稀代の決闘者
--Performapal Greatest Duelist
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Action Spell! "Miracle"!
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Search 1 "Supreme King Dragon","Supreme King Gate", or "The Supreme King's Soul"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Each player can banish 1 Spell from their Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Action Spell! "Evasion"!
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetOperation(s.atkop2)
	c:RegisterEffect(e4)
end
s.listed_names={92428405}
s.listed_series={0x10f8,0x20f8}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	return Duel.GetAttacker():IsControler(tp) or bc:IsControler(tp)
end
function s.rmfilter(c)
	return c:IsSpell() and c:IsAbleToRemove()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsRelateToBattle() and a:IsControler(tp) then
		--Cannot be destroyed by that battle
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
	--Battle damage you take is halved
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.thfilter(c)
	return ((c:IsMonster() and (c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8))) or c:IsCode(92428405)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local turn_p=Duel.GetTurnPlayer()
	local step=turn_p==0 and 1 or -1
	for p=turn_p,1-turn_p,step do
		local g=Duel.GetMatchingGroup(s.rmfilter,p,LOCATION_DECK,0,1,nil)
		if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
			local rg=g:Select(p,1,1,nil)
			if #rg==0 then return end
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.thfilter2(c)
	return c:IsFaceup() and c:IsSpell() and c:IsAbleToHand()
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	local p
	if not bc then
		p=1-Duel.GetAttacker():GetControler()
	else
		p=bc:GetControler()
	end
	local g=Duel.GetMatchingGroup(s.thfilter2,p,LOCATION_REMOVED,0,1,nil)
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local tc=g:Select(p,1,1,nil):GetFirst()
		if not tc then return end
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
			and tc:IsDiscardable(REASON_EFFECT) then
			Duel.ConfirmCards(1-p,tc)
			Duel.BreakEffect()
			if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)==0 then return end
			Duel.NegateAttack()
		end
	end
end