--流星極輝巧群
--Meteoroa Drytron
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Add up to 2 of your banished "Drytron" cards to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg) return eg:IsExists(aux.FaceupFilter(Card.IsSetCard,SET_DRYTRON),1,nil) end)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Ritual Summon 1 Machine Ritual Monster from your hand or GY
	local params={filter=s.ritualfilter,lv=Card.GetAttack,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE,requirementfunc=Card.GetAttack}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.ritualcost)
	e2:SetTarget(Ritual.Target(params))
	e2:SetOperation(Ritual.Operation(params))
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRYTRON}
s.listed_names={22398665}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,aux.FilterBoolFunction(Card.IsSetCard,SET_DRYTRON),1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,aux.FilterBoolFunction(Card.IsSetCard,SET_DRYTRON),1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_DRYTRON) and c:IsFaceup() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.ritualfilter(c)
	return c:GetAttack()>0 and c:IsRitualMonster() and c:IsRace(RACE_MACHINE)
end
function s.matfilter(c)
	return c:IsRace(RACE_MACHINE) and c:GetAttack()>0
end
function s.ritualcostfilter(c)
	return c:IsCode(22398665) and not c:IsPublic()
end
function s.ritualcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ritualcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.ritualcostfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end