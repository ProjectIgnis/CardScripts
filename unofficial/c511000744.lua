--Harmonic Geoglyph
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
function s.filter(c,e,tp)
	if not c:IsType(TYPE_SYNCHRO) or c:GetLevel()%2~=0 then return false end
	s.Reset={}
	return Duel.IsExistingMatchingCard(s.tmatfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
end
function s.tmatfilter(c,e,tp,syncard)
	if not c:IsType(TYPE_TUNER) or not c:IsCanBeSynchroMaterial(syncard) or c:IsFacedown() then return false end
	local e2
	if c:IsHasEffect(EFFECT_SYNCHRO_LEVEL) then
		e2=c:GetCardEffect(EFFECT_SYNCHRO_LEVEL)
		local eff=e2:Clone()
		c:RegisterEffect(eff)
		e2:SetValue(2)
	else
		e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		e2:SetValue(2)
		e2:SetReset(RESET_CHAIN)
		c:RegisterEffect(e2)
	end
	table.insert(s.Reset,e2)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil,e,syncard)
	g:AddCard(c)
	local res=syncard:IsSynchroSummonable(c,g)
	for i,eff in ipairs(s.Reset) do
		eff:Reset()
	end
	s.Reset={}
	return res
end
function s.matfilter(c,e,syncard)
	if not c:IsType(TYPE_SYNCHRO) or not c:IsCanBeSynchroMaterial(syncard) or not c:IsLevelAbove(6) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())then return false end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local e2
	if c:IsHasEffect(EFFECT_SYNCHRO_LEVEL) then
		e2=c:GetCardEffect(EFFECT_SYNCHRO_LEVEL)
		local eff=e2:Clone()
		c:RegisterEffect(eff)
		e2:SetValue(2)
	else
		e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		e2:SetValue(2)
		e2:SetReset(RESET_CHAIN)
		c:RegisterEffect(e2)
	end
	table.insert(s.Reset,e1)
	table.insert(s.Reset,e2)
	return true
end
s.Reset={}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	local g=Duel.GetMatchingGroup(c511001640.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local mc=Duel.SelectMatchingCard(tp,s.tmatfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,tc):GetFirst()
		local sg=Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil,e,tc)
		sg:AddCard(mc)
		Duel.SynchroSummon(tp,tc,mc,sg)
	end
end
