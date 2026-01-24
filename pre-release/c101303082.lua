--JP name
--Jade Dragon Mech
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If this card is Special Summoned: You can send 1 Machine Tuner from your Deck to the GY, or if you control a monster whose current Level is different from its original Level, you can Special Summon it instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgsptg)
	e1:SetOperation(s.tgspop)
	c:RegisterEffect(e1)
	--If this Synchro Summoned card is destroyed by card effect and sent to the GY: You can banish any number of Tuners from your GY, then target that many cards on the field; destroy them
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.difflvfilter(c)
	return c:HasLevel() and c:IsFaceup() and not c:IsLevel(c:GetOriginalLevel())
end
function s.tgspfilter(c,e,tp,mmz_extra_chk)
	return c:IsRace(RACE_MACHINE) and (c:IsAbleToGrave() or (mmz_extra_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tgsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mmz_extra_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.difflvfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mmz_extra_chk) end
	if not mmz_extra_chk then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tgspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_extra_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.difflvfilter,tp,LOCATION_MZONE,0,1,nil)
	local hint=mmz_extra_chk and aux.Stringid(id,2) or HINTMSG_TOGRAVE
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local sc=Duel.SelectMatchingCard(tp,s.tgspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_extra_chk):GetFirst()
	if not sc then return end
	local op=1
	if mmz_extra_chk then
		local b1=sc:IsAbleToGrave()
		local b2=sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	end
	if op==1 then
		Duel.SendtoGrave(sc,REASON_EFFECT)
	elseif op==2 then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSynchroSummoned() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT)
end
function s.descostfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local max_target_count=Duel.GetTargetCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_GRAVE,0,1,max_target_count,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(#g)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local target_count=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,target_count,target_count,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end