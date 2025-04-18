--シャイニング・ドロー
--Shining Draw
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--To activate this card, you must draw it for your normal draw in your Draw Phase, reveal it, and keep it revealed until the Main Phase 1
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_DRAW)
	e0:SetCondition(function(e) return Duel.IsPhase(PHASE_DRAW) and e:GetHandler():IsReason(REASON_RULE) end)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsPhase(PHASE_MAIN1) end)
	e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():HasFlagEffect(id) end end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_UTOPIA,SET_ZW}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local c=e:GetHandler()
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
		--Reveal it, and keep it revealed until the Main Phase 1
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_MAIN1)
		c:RegisterEffect(e1)
	end
end
function s.tgfilter(c,e,tp,eq_chk)
	return c:IsSetCard(SET_UTOPIA) and c:IsType(TYPE_XYZ) and c:IsFaceup() and (eq_chk or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c))
end
function s.spfilter(c,e,tp,mc)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsSetCard(SET_UTOPIA) and not c:IsCode(mc:GetCode()) and mc:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.eqfilter(c,tp)
	return c:IsSetCard(SET_ZW) and c:IsMonster() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local b=chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE)
		if e:GetLabel()==0 then
			return b and s.utopiafilter(chkc)
		else
			return b and s.filter2(chkc,e,tp)
		end
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then ft=ft-1 end
	local eq_chk=ft>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,tp)
	--Equip any number of "ZW -" monsters with different names from your Deck/Extra Deck to it
	local b1=eq_chk and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,eq_chk)
	--Special Summon from your Extra Deck, 1 "Utopia" Xyz Monster with a different name from that target, by using that target as material
	local b2=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,false)
	if chk==0 then return b1 or b2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eq_chk):GetFirst()
	b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if op==1 then
		--Equip any number of "ZW -" monsters with different names from your Deck/Extra Deck to it
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft==0 then return end
		local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil,tp)
		if #g==0 then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_EQUIP)
		local c=e:GetHandler()
		for sc in sg:Iter() do
			if Duel.Equip(tp,sc,tc,true,true) then
				--Equip limit
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetValue(function(e,c) return c==tc end)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
		end
		Duel.EquipComplete()
	elseif op==2 then
		--Special Summon from your Extra Deck, 1 "Utopia" Xyz Monster with a different name from that target, by using that target as material
		if tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc):GetFirst()
		if sc then
			sc:SetMaterial(tc)
			Duel.Overlay(sc,tc)
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
			sc:CompleteProcedure()
		end
	end
end
