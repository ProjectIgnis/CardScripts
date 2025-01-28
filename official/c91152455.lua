--メタル化・鋼炎装甲
--Flame Coating Metalmorph
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster that cannot be Normal Summoned/Set and mentions "Max Metalmorph" from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_MAX_METALMORPH}
function s.costfilter(c,tp)
	return c:ListsCode(CARD_MAX_METALMORPH) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,tp)
		if res then e:SetLabel(1) end
		return res
	end
	local rc=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,tp):GetFirst()
	Duel.Release(rc,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:ListsCode(CARD_MAX_METALMORPH) and c:IsMonster() and not c:IsSummonableCard()
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and (e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		e:SetLabel(0)
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	local c=e:GetHandler()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		if not (c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		c:CancelToGrave(true)
		Duel.BreakEffect()
		if not tc:EquipByEffectAndLimitRegister(e,tp,c,nil,true) then return end
		--Equip limit
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return c==tc end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e0)
		--If the equipped monster would be destroyed by battle or card effect, you can send this card to the GY instead
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(s.desreptg)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec:IsReason(REASON_BATTLE|REASON_EFFECT) and not ec:IsReason(REASON_REPLACE)
		and c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96) and Duel.SendtoGrave(c,REASON_EFFECT)>0
end