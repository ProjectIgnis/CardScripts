--JP name
--Angelechy Disturbance
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Give control of 1 "Angelechy" monster you control to your opponent (until the End Phase), then if your opponent controls a face-up card(s) in its adjacent Monster Zones and/or Spell & Trap Zones, their effects are negated
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.ctrltg)
	e1:SetOperation(s.ctrlop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; add 1 "Angelechy" Spell/Trap from your Deck to your hand, except "Angelechy Disturbance"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ANGELECHY}
function s.ctrlfilter(c)
	return c:IsSetCard(SET_ANGELECHY) and c:IsControlerCanBeChanged() and c:IsFaceup()
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not (tc and Duel.GetControl(tc,1-tp,PHASE_END,1) and tc:IsControler(1-tp)) then return end
	local c=e:GetHandler()
	local break_chk=false
	local function optnegate(loc,nseq)
		local nc=Duel.GetFieldCard(1-tp,loc,nseq)
		if nc and nc:IsNegatable() then
			if not break_chk then
				break_chk=true
				Duel.BreakEffect()
			end
			nc:NegateEffects(c)
		end
	end
	local seq=tc:GetSequence()
	optnegate(LOCATION_SZONE,seq) --down
	if seq>0 then optnegate(LOCATION_MZONE,seq-1) end --left
	if seq<4 then optnegate(LOCATION_MZONE,seq+1) end --right
	if seq==1 then optnegate(LOCATION_MZONE,5) elseif seq==3 then optnegate(LOCATION_MZONE,6) end --up
end
function s.thfilter(c)
	return c:IsSetCard(SET_ANGELECHY) and c:IsSpellTrap() and not c:IsCode(id) and c:IsAbleToHand()
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