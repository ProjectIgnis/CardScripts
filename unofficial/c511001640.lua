--アクセル・シンクロ
--Accel Synchro
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
function s.matfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup() and c:IsCanBeSynchroMaterial()
end
function s.spfilter(c,tp,mg)
	return c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local reset={}
		for tc in aux.Next(mg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
			e1:SetReset(RESET_CHAIN)
			e1:SetOperation(s.synop)
			tc:RegisterEffect(e1,true)
			table.insert(reset,e1)
			if tc:IsControler(1-tp) then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SYNCHRO_MATERIAL)
				e2:SetReset(RESET_CHAIN)
				tc:RegisterEffect(e2)
				table.insert(reset,e2)
			end
		end
		local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local reset={}
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		e1:SetOperation(s.synop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		table.insert(reset,e1)
		if tc:IsControler(1-tp) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SYNCHRO_MATERIAL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			table.insert(reset,e2)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sync=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,mg):GetFirst()
	if sync then
		Duel.SynchroSummon(tp,sync,nil,mg)
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
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return sg:GetSum(Card.GetLevel)/2==lv,true
end