--T.G.EX Searcher
function c210001000.initial_effect(c)
	--must be special sumoned properly
	c:EnableReviveLimit()
	--link prochedure durp
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x27),2,2,c210001000.mcheck)
	--treat 1 synchro monster as a damn tuner
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,210001000)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c210001000.ttcondition)
	e1:SetTarget(c210001000.tttarget)
	e1:SetOperation(c210001000.ttoperation)
	c:RegisterEffect(e1)
	--when destroyed add a tuner
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCountLimit(1,210001000)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetTarget(c210001000.attarget)
	e2:SetOperation(c210001000.atoperation)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetCountLimit(1,210001000)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c210001000.sptarget)
	e3:SetOperation(c210001000.spoperation)
	c:RegisterEffect(e3)
end
--check if there at least 1 tuner in used group
function c210001000.mcheck(sg,lc,tp)
	return sg:IsExists(Card.IsType,1,nil,TYPE_TUNER,lc,SUMMON_TYPE_SYNCHRO,tp)
end
--check if a card point to 2 synchro monster
function c210001000.ttfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
--effect 1 condition
function c210001000.ttcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lk=c:GetLinkedGroup()
	return lk:IsExists(c210001000.ttfilter1,2,nil)
end
--check if there a card that can be treated as a tuner
function c210001000.ttfilter2(c,g)
	return c210001000.ttfilter1(c) and g:IsContains(c) and not c:IsType(TYPE_TUNER)
end
--effect 1 target
function c210001000.tttarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lk=c:GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c210001000.ttfilter2(chkc,lk) end
	if chk==0 then return Duel.IsExistingTarget(c210001000.ttfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lk) end
	Duel.SelectTarget(tp,c210001000.ttfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lk)
end
--effect 1 operation
function c210001000.ttoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not tc:IsType(TYPE_TUNER) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		tc:RegisterEffect(e1)
	end
end
--check if there a tuner
function c210001000.atfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
--effect 2 target
function c210001000.attarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001000.atfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
--effect 2 operation
function c210001000.atoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210001000.atfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--check if there a monster wich original level
function c210001000.spfilter1(c,lc,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c210001000.spfilter2,tp,LOCATION_EXTRA,0,1,nil,lc,c,e,tp)
end
--check if there a synchro monster that level match the sum
function c210001000.spfilter2(c,lc,tc,e,tp)
	local sum=lc:GetLink()+tc:GetOriginalLevel()
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()==sum and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(lc,tc),c)>0
end
--effect 3 target
function c210001000.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c:IsAbleToRemove() and chkc:IsLocation(LOCATION_MZONE) and c210001000.spfilter1(chkc,c,e,tp) end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,69832741) and c:IsAbleToRemoveAsCost() 
		and Duel.IsExistingTarget(c210001000.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c,e,tp) end
	local tg=Duel.SelectTarget(tp,c210001000.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c,e,tp)
	tg:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,tg:GetCount(),0,0)
end
--effect 3 operation
function c210001000.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c and tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.Remove(c,0,REASON_EFFECT)~=0 and Duel.Remove(tc,0,REASON_EFFECT)~=0 then
			local tg=Duel.GetMatchingGroup(c210001000.spfilter2,tp,LOCATION_EXTRA,0,nil,c,tc,e,tp)
			if tg:GetCount()>0 then
				tc=tg:Select(tp,1,1,nil)
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end