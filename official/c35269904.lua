-- 三戦の号
-- Triple Tactic
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Set 1 Normal Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not re:IsActiveType(TYPE_MONSTER) end)
end
s.listed_names={id}
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
function s.stfilter(c,tohand_chk)
	local typ=c:GetType()
	return (typ==TYPE_TRAP or typ==TYPE_SPELL) and ((tohand_chk and c:IsAbleToHand()) or c:IsSSetable()) and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	local tohand_chk=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,tohand_chk) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tohand_chk=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	if not Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,tohand_chk) then return end
	local desc=tohand_chk and aux.Stringid(id,1) or HINTMSG_SET
	Duel.Hint(HINT_SELECTMSG,tp,desc)
	local sc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tohand_chk):GetFirst()
	if not sc then return end
	if tohand_chk and sc:IsAbleToHand() and (not sc:IsSSetable() or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		if Duel.SendtoHand(sc,nil,REASON_EFFECT)==0 then return end
		Duel.ConfirmCards(1-tp,sc)
	else
		if Duel.SSet(tp,sc)==0 then return end
		-- Cannot be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_CANNOT_ACT+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
	end
end