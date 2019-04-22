--Chaos Hundred Universe
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp,tid)
	local code=c:GetCode()
	local class=_G["c"..code]
	if class==nil then return false end
	local no=class.xyz_number
	return no and no>=101 and no<=107 and c:IsSetCard(0x1048) and c:IsReason(REASON_DESTROY) and c:GetTurnID()==tid 
		and c:GetPreviousControler()==tp
end
function s.spfilter(c,e,tp)
	local code=c:GetCode()
	local class=_G["c"..code]
	if class==nil then return false end
	local no=class.xyz_number
	return no and no>=101 and no<=107 and c:IsSetCard(0x1048) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tid=Duel.GetTurnCount()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,tid)
	local ct=#g
	local ect=cCARD_SUMMON_GATE and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and cCARD_SUMMON_GATE[tp]
	if chk==0 then return ct>0 and Duel.GetLocationCountFromEx(tp)>=ct and Duel.GetLocationCountFromEx(1-tp)>=ct 
		and g:IsExists(Card.IsCanBeSpecialSummoned,ct,nil,e,0,tp,false,false) and (not ect or ect>=ct) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,ct,nil,e,tp) 
		and (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or ct<2) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,Duel.GetTurnCount())
	local ct=#g
	if Duel.GetLocationCountFromEx(tp)<ct or Duel.GetLocationCountFromEx(1-tp)<ct then return end
	if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,ct,nil,e,tp) then return end
	if not g:IsExists(Card.IsCanBeSpecialSummoned,ct,nil,e,0,tp,false,false) then return end
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local ect=cCARD_SUMMON_GATE and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and cCARD_SUMMON_GATE[tp]
	if ect~=nil and ct>ect then return end
	if ct>0 then
		local tc=g:GetFirst()
		while tc do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,ct,ct,nil,e,tp)
		local tc2=g2:GetFirst()
		while tc2 do
			Duel.SpecialSummonStep(tc2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
			tc2=g2:GetNext()
		end
		Duel.SpecialSummonComplete()
	end
end
