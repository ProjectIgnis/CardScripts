--RUM－七皇の剣
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x48,0x1048,0x1073}
s.listed_names={511000296}
function s.filter1(c,e,tp)
	local m = c:GetMetatable(true)
	if not m then return false end
	local no, rk=tonumber(m.xyz_number), c:GetRank()
	if not no or no < 101 or no > 107 or not c:IsSetCard(0x48) or rk <= 0 then return false end
	return (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
		or (c:IsLocation(LOCATION_GRAVE|LOCATION_EXTRA) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and ((c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0)
		or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c) > 0)))
end
function s.filter2(c,e,tp,mc,rk)
	return (c:IsSetCard(0x1048) or c:IsSetCard(0x1073) or c:IsCode(511000296)) and mc:IsCanBeXyzMaterial(c) and c:IsRank(rk)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c) > 0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA) and s.filter1(chkc,e,tp) end
	if chk == 0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if not e:GetHandler():IsLocation(LOCATION_MZONE) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,e:GetHandler():GetLocation())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE|LOCATION_EXTRA) then
		if (tc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 and not tc:IsHasEffect(EFFECT_NECRO_VALLEY))
			or (tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,tc) > 0)then
			if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				Duel.SpecialSummonComplete()
			end
		end
		if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,tc,e,tp,tc,tc:GetRank()+1)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(58988903,0)) then
		local sc, mg=sg:Select(tp,1,1,nil):GetFirst(), Group.CreateGroup()
		if tc:IsLocation(LOCATION_MZONE) then
			if tc:GetOverlayCount() > 0 then
				Duel.Overlay(sc, tc:GetOverlayGroup())
			end
			mg:AddCard(tc)
			Duel.Overlay(sc, tc)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
