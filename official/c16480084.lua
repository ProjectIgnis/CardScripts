--エヴォルダー・ペルタ
--Evolsaur Pelta
local s,id=GetID()
function s.initial_effect(c)
	--Gains 500 DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(s.deftg)
	e1:SetOperation(s.defop)
	c:RegisterEffect(e1)
	--Check if it is summoned by the effect of an "Evoltile" monster before it leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)
	--Add 1 "Evoltile" monste from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(s.thcond)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_EVOLTILE}
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,tp,-500)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--This card loses 500 DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsEvoltileSummoned() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetLabelObject():GetLabel()==1
end
function s.thfilter(c)
	return c:IsSetCard(SET_EVOLTILE) and c:IsMonster() and c:IsAbleToHand()
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