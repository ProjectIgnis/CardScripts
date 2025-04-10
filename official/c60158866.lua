--不朽の七皇
--Seventh Eternity
--Scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Negate or detach
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}
function s.tgfilter(c,tp)
	local ovct=c:GetOverlayCount()
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and (s.nmbrfilter(c) or c:GetOverlayGroup():IsExists(s.nmbrfilter,1,nil))
		and (Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
		or (ovct>0 and c:CheckRemoveOverlayCard(tp,ovct,REASON_EFFECT)))
end
function s.nmbrfilter(c)
	local no=c.xyz_number
	return c:IsSetCard(SET_NUMBER) and no and no>=101 and no<=107
end
function s.disfilter(c,atk)
	return c:IsNegatableMonster() and c:IsAttackBelow(atk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup()
			and (s.nmbrfilter(chkc) or chkc:GetOverlayGroup():IsExists(s.nmbrfilter,1,nil))) then return false end
		local b1_rdr=Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,chkc:GetAttack())
		local ovct=chkc:GetOverlayCount()
		local b2_rdr=ovct>0 and chkc:CheckRemoveOverlayCard(tp,ovct,REASON_EFFECT)
		local op_rdr=e:GetLabel()
		return (b1_rdr and op_rdr==1) or (b2_rdr and op_rdr==2)
	end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local b1=Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack())
	local b2=tc:GetOverlayCount()>0 and tc:CheckRemoveOverlayCard(tp,tc:GetOverlayCount(),REASON_EFFECT)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==1 and tc:IsFaceup() then
		--Negate the effects of 1 opponent's monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local ngc=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack()):GetFirst()
		if not ngc then return end
		Duel.HintSelection(ngc,true)
		local c=e:GetHandler()
		Duel.NegateRelatedChain(ngc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		ngc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		ngc:RegisterEffect(e2)
	elseif op==2 then
		--Detach all materials from the target
		local og=tc:GetOverlayGroup()
		if #og==0 then return end
		if Duel.SendtoGrave(og,REASON_EFFECT)~=#og or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil)
			if #sc==0 then return end
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end