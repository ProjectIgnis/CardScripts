--JP Name
--Angelechy Verdict
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Apply this effect based on the number of "Angelechy" Monster Cards on the field
	--● 1 to 4: Negate the effects of 1 face-up card your opponent controls
	--● 5+: Banish all cards your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; send 1 "Angelechy" card from your hand or face-up field to the GY, then you can place 1 "Angelechy" monster with a different name than the cards in your Spell & Trap Zone, from your Extra Deck in your Spell & Trap Zone as a face-up Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ANGELECHY}
function s.countfilter(c)
	return c:IsSetCard(SET_ANGELECHY) and c:IsMonsterCard() and c:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(s.countfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		if ct==0 then return false end
		if ct<5 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.countfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if ct==0 then return end
	if ct<5 then
		--● 1 to 4: Negate the effects of 1 face-up card your opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local tc=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc)
			tc:NegateEffects(e:GetHandler(),nil,true)
		end
	else
		--● 5+: Banish all cards your opponent controls
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.tgfilter(c)
	return c:IsSetCard(SET_ANGELECHY) and c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.plfilter(c,...)
	return c:IsSetCard(SET_ANGELECHY) and not c:IsForbidden() and not (... and c:IsCode(...))
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0
		or not g:GetFirst():IsLocation(LOCATION_GRAVE)
		or Duel.GetLocationCount(tp,LOCATION_SZONE,0)==0 then return end
	local codes=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_STZONE,0,nil):GetClass(Card.GetCode)
	local plg=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_EXTRA,0,nil,codes)
	if #plg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local plc=plg:Select(tp,1,1,nil):GetFirst()
	if not plc then return end
	Duel.BreakEffect()
	if Duel.MoveToField(plc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		plc:RegisterEffect(e1)
	end
end