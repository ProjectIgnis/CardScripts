--ペンデュラム・エクシーズ
--Pendulum XYZ
--fixed by Larry126
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
local function reglevel(c,tc,lv)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(lv)
	tc:RegisterEffect(e1,true)
	return e1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		if #g~=2 then return false end
		local tc1=g:GetFirst()
		local tc2=g:GetNext()
		local e1=reglevel(e:GetHandler(),tc1,tc2:GetLevel())
		local e2=reglevel(e:GetHandler(),tc2,tc1:GetLevel())
		local res=Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,g,g)
		if e1 then e1:Reset() end
		if e2 then e2:Reset() end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #pg~=2 then return false end
	local tc1=pg:GetFirst()
	local tc2=pg:GetNext()
	local e1=reglevel(e:GetHandler(),tc1,tc2:GetLevel())
	local e2=reglevel(e:GetHandler(),tc2,tc1:GetLevel())
	local g=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,pg,pg)
	if g and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=g:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,pg,nil,2,2)
	else
		if e1 then e1:Reset() end
		if e2 then e2:Reset() end
	end
end