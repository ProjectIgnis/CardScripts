--七皇再生
--Rebirth of the Seventh Emperors
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 of your banished Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
	if chk==0 then return #sg>0 and sg:FilterCount(Card.IsReleasable,nil)==#sg end
	local ct=Duel.Release(sg,REASON_COST)
	Duel.SetTargetParam(ct+1)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
		if e:GetLabel()==1 then ft=Duel.GetMZoneCount(tp,sg) end
		e:SetLabel(0)
		return ft>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,300)
end
function s.attachfilter(c)
	local no=c.xyz_number
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and no and no>=101 and no<=107 and c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.attachfilter),tp,LOCATION_REMOVED|LOCATION_GRAVE,0,tc)
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and ct>0 and #g>0 and not tc:IsImmuneToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mg=g:Select(tp,1,ct,nil)
		if #mg>0 then
			Duel.HintSelection(mg)
			Duel.BreakEffect()
			Duel.Overlay(tc,mg)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--During the End Phase of the turn you activated this card, each player takes 300 damage for each card in their hand
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(tp,Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*300,REASON_EFFECT,true)
	Duel.Damage(1-tp,Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*300,REASON_EFFECT,true)
	Duel.RDComplete()
end