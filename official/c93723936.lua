--白き森のあくま
--Scourge of the White Forest
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of 1 face-up card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Set this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WHITE_FOREST}
function s.discostfilter(c,handler_c)
	local eqpg=c:GetEquipGroup()
	return c:IsType(TYPE_SYNCHRO)
		and Duel.IsExistingTarget(Card.IsNegatable,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,eqpg+Group.FromCards(c,handler_c))
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.discostfilter,1,false,nil,nil) end
	local rc=Duel.SelectReleaseGroupCost(tp,s.discostfilter,1,1,false,nil,nil):GetFirst()
	e:SetLabel(rc:IsSetCard(SET_WHITE_FOREST) and 1 or 0)
	Duel.Release(rc,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsNegatable() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	if e:GetLabel()==1 then
		Duel.SetTargetParam(1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
	e:SetLabel(0)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		local c=e:GetHandler()
		--Negate its effects until the end of this turn
		tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		Duel.AdjustInstantly(tc)
		if tc:IsDisabled() and Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end