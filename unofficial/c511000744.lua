--ハーモニック・ジオグリフ
--Harmonic Geoglyph
local s,id=GetID()
function s.initial_effect(c)
	--synchro custom
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return #sg-1+e:GetHandler():GetLevel()==lv,true
end
function s.tunerfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSynchroMaterial() and c:IsFaceup()
end
function s.matfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSynchroMaterial() and c:IsLevelAbove(6) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.spfilter(c,tp,tuners,nontuners)
	return c:IsType(TYPE_SYNCHRO) and c:HasLevel() and c:GetLevel()%2==0 and c:IsSynchroSummonable(nil,tuners+nontuners) and Duel.GetLocationCountFromEx(tp,tp,tuners,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local tuners=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_MZONE,0,nil)
		local nontuners=Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
		local reset={}
		for tc in aux.Next(tuners) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SYNCHRO_CHECK)
			e1:SetValue(s.syncheck)
			e1:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e1,true)
			table.insert(reset,e1)
		end
		for tc in aux.Next(nontuners) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SYNCHRO_CHECK)
			e1:SetValue(s.syncheck)
			e1:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SYNCHRO_MATERIAL)
			e2:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e2)
			table.insert(reset,e1)
			table.insert(reset,e2)
		end
		local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,tuners,nontuners)
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tuners=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_MZONE,0,nil)
	local nontuners=Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
	local reset={}
	for tc in aux.Next(tuners) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_CHECK)
		e1:SetValue(s.syncheck)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		table.insert(reset,e1)
	end
	for tc in aux.Next(nontuners) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_CHECK)
		e1:SetValue(s.syncheck)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SYNCHRO_MATERIAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		table.insert(reset,e1)
		table.insert(reset,e2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sync=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,tuners,nontuners):GetFirst()
	if sync then
		Duel.SynchroSummon(tp,sync,nil,tuners+nontuners)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetOperation(function()
			for _,eff in ipairs(reset) do
				eff:Reset()
			end
		end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sync:RegisterEffect(e1,true)
	else
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
	end
end
function s.syncheck(e,c)
	c:AssumeProperty(ASSUME_LEVEL,2)
	return true
end