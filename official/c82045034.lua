--百雷のサンダー・ドラゴン
--The Hundred Thunder Dragons
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spfilter2(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetAbsoluteRange(tp,1,0)
		e2:SetTarget(s.splimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local ct=Duel.SpecialSummonComplete()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_GRAVE,0,nil,code,e,tp)
		if ct==0 or ft<=0 or #sg==0 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local g=sg:Select(tp,ft,ft,nil)
			local dg=g:GetFirst()
			for dg in aux.Next(g) do
				Duel.SpecialSummonStep(dg,0,tp,tp,false,false,POS_FACEUP)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetValue(LOCATION_REMOVED)
				e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
				dg:RegisterEffect(e3,true)
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_FIELD)
				e4:SetRange(LOCATION_MZONE)
				e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e4:SetAbsoluteRange(tp,1,0)
				e4:SetTarget(s.splimit)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				dg:RegisterEffect(e4,true)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.splimit(e,c)
	return not c:IsRace(RACE_THUNDER)
end