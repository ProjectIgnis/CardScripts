--破械式鬼シャラ
--Unchained Ogre Shara
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--During the Main Phase (Quick Effect): You can discard this card; Special Summon 1 Fiend monster from your hand, then destroy 1 card you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.handsptg)
	e1:SetOperation(s.handspop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--If a card(s) on the field is destroyed by card effect, except "Unchained Ogre Shara", or by battle, while this card is in your GY: You can Special Summon this card (but place it on the bottom of the Deck when it leaves the field) or add it to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.selfspthcon)
	e2:SetTarget(s.selfspthtg)
	e2:SetOperation(s.selfspthop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.handspfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.handsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.handspfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
end
function s.handspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.handspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
function s.selfspthconfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.selfspthcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) or not eg:IsExists(s.selfspthconfilter,1,nil) then return false end
	if r&REASON_BATTLE>0 then return true end
	if Duel.IsChainSolving() then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) and rc:IsFaceup() then
			return not rc:IsCode(id)
		else
			local code1,code2=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
			return code1~=id and code2~=id
		end
	else
		if re then
			return not re:GetHandler():IsCode(id)
		else
			return not eg:GetFirst():IsPreviousCodeOnField(id)
		end
	end
	return false
end
function s.selfspthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.selfspthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	aux.ToHandOrElse(c,tp,
		function()
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
				--Place it on the bottom of the Deck when it leaves the field
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,2))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetValue(LOCATION_DECKBOT)
				e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
				c:RegisterEffect(e1,true)
			end
		end,
		aux.Stringid(id,3)
	)
end