--フォーメーション・ユニオン
--Formation Union
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_card_types={TYPE_UNION}
function s.unioneqfilter(c,tp)
	return c:IsType(TYPE_UNION) and c:IsFaceup() and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,c,c)
end
function s.eqfilter(c,ec)
	return ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec,c) and c:IsFaceup()
end
function s.spfilter(c,e,tp)
	return c:IsHasEffect(EFFECT_UNION_STATUS) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_STZONE) and s.spfilter(chkc,e,tp) end
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.unioneqfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_STZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectTarget(tp,s.unioneqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,ec,ec)
		e:SetLabelObject(ec)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,ec,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_STZONE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Equip 1 Union monster you control to 1 appropriate monster you control
		local ec=e:GetLabelObject()
		if not (ec:IsRelateToEffect(e) and ec:IsControler(tp)) then return end
		local tc=(Duel.GetTargetCards(e)-ec):GetFirst()
		if not (tc and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
			Duel.SendtoGrave(ec,REASON_RULE,PLAYER_NONE,PLAYER_NONE)
		elseif aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
			aux.SetUnionState(ec)
		end
	elseif op==2 then
		--Special Summon 1 equipped Union Monster Card from your Spell & Trap Zone in Attack Position
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end