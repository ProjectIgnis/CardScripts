--ＥＭ稀代の決闘者
--Performapal Duelist Extraordinaire
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Return this card to the hand, and if you do, banish 1 Spell from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function() return Duel.GetAttacker() and Duel.GetAttackTarget() end)
	e1:SetTarget(s.selfthtg)
	e1:SetOperation(s.selfthop)
	c:RegisterEffect(e1)
	--Add 1 "Supreme King Dragon" monster, "Supreme King Gate" monster, or "Soul of the Supreme King" from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
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
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--The attacked player can apply the following effect: ● Add 1 of your banished Spells to your hand, then discard it, and if you do, negate that attack.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_names={92428405} --"Soul of the Supreme King"
s.listed_series={SET_SUPREME_KING_DRAGON,SET_SUPREME_KING_GATE}
function s.rmfilter(c)
	return c:IsSpell() and c:IsAbleToRemove()
end
function s.selfthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.selfthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	local bg=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget()):Match(function(c) return c:IsRelateToBattle() and c:IsControler(tp) end,nil)
	if #bg==0 then return end
	for bc in bg:Iter() do
		--For that battle, your monster cannot be destroyed
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		bc:RegisterEffect(e1)
	end
	--For that battle, the battle damage you take is halved
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
function s.thfilter(c)
	return ((c:IsSetCard({SET_SUPREME_KING_DRAGON,SET_SUPREME_KING_GATE}) and c:IsMonster()) or c:IsCode(92428405)) and c:IsAbleToHand()
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
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local turn_p=Duel.GetTurnPlayer()
	local step=turn_p==0 and 1 or -1
	for p=turn_p,1-turn_p,step do
		local g=Duel.GetMatchingGroup(s.rmfilter,p,LOCATION_DECK,0,1,nil)
		if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
			local rg=g:Select(p,1,1,nil)
			if #rg>0 then
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=Duel.GetAttackTarget()
	local attacked_player=bc and bc:GetControler() or (1-Duel.GetAttacker():GetControler())
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,attacked_player,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,attacked_player,1)
end
function s.rmthfilter(c)
	return c:IsSpell() and c:IsFaceup() and c:IsAbleToHand()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	local attacked_player=bc and bc:GetControler() or (1-Duel.GetAttacker():GetControler())
	local g=Duel.GetMatchingGroup(s.rmthfilter,attacked_player,LOCATION_REMOVED,0,1,nil)
	if #g>0 and Duel.SelectYesNo(attacked_player,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,attacked_player,HINTMSG_ATOHAND)
		local sc=g:Select(attacked_player,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND)
			and sc:IsDiscardable(REASON_EFFECT) then
			Duel.BreakEffect()
			if Duel.SendtoGrave(sc,REASON_EFFECT|REASON_DISCARD)>0 then
				Duel.NegateAttack()
			end
		end
	end
end
