--神殿への光
--Light to the Temple
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsCode(1353770) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	if tc:IsType(TYPE_FIELD) then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if Duel.IsDuelType(DUEL_1_FIELD) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			of=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
			if of and Duel.Destroy(of,REASON_RULE)==0 then
				Duel.SendtoGrave(c,REASON_RULE)
				return false
			else
				Duel.BreakEffect()
			end
		else
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then
				Duel.SendtoGrave(c,REASON_RULE)
				return false
			else
				Duel.BreakEffect()
			end
		end
	end
	Duel.MoveToField(tc,tp,tp,tc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE,POS_FACEUP,true)
end