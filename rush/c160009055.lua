--羊界－墓地に怨念
--Wooly Wonderland - Graveyard Grudge
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetAttacker():IsControler(1-tp) then return false end
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsControler(tp) and bc:IsFaceup() and bc:IsRace(RACE_BEAST) and bc:IsAttackPos() and bc:IsType(TYPE_NORMAL)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,4) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,4,REASON_COST)==0 then return end
	--Effect
	local og=Duel.GetOperatedGroup()
	local bc=Duel.GetAttackTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		--Decrease ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(-2000)
		bc:RegisterEffect(e1)
		og:Match(Card.IsLocation,nil,LOCATION_GRAVE):Match(Card.IsAbleToHand,nil)
		if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local hg=og:Select(tp,1,4,nil)
			if #hg>0 then
				Duel.SendtoHand(hg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,hg)
			end
		end
	end
end
