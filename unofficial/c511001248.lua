--ゴースト・フリート・サルベージ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	local og=c:GetMaterial():Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	local ct=0
	if #og>2 then
		ct=2
	else
		ct=#og
	end
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>ct
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.filter,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:Filter(s.filter,nil,e,tp):GetFirst()
	if tc then
		local og=tc:GetMaterial():Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false):Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		local ct=0
		if #og>2 then
			ct=2
		else
			ct=#og
		end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=ct then return end
		if #og>2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			og=og:Select(tp,2,2,nil)
		end
		og:AddCard(tc)
		local tg=og:GetFirst()
		for tg in aux.Next(og) do
			Duel.SpecialSummonStep(tg,0,tp,tp,false,false,POS_FACEUP)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tg:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tg:RegisterEffect(e3)
		end
		Duel.SpecialSummonComplete()
	end
end
