--ダークインファント@イグニスター
--Dark Infant @Ignister
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Add 1 "Ignister A.I.Land" to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_IGNISTER}
s.listed_names={59054773}
function s.matfilter(c,scard,sumtype,tp)
	return not c:IsLinkMonster() and c:IsSetCard(SET_IGNISTER,scard,sumtype,tp)
end
function s.thfilter(c)
	return c:IsCode(59054773) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
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
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsMonsterEffect()
		and re:GetHandler():GetBaseAttack()==2300 and re:GetHandler():IsRace(RACE_CYBERSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()&ZONES_MMZ
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,nil,nil,zone)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone()&ZONES_MMZ
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,nil,zone)>0 then
		Duel.MoveSequence(c,math.log(zone,2))
		if c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local att=c:AnnounceAnotherAttribute(tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetValue(att)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end