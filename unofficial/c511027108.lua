--ヘル・チューニング
--Hell Tuning
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(function(e,c) return c:GetFlagEffect(id)>0 end)
		ge1:SetValue(1)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and s.cfilter(eg:GetFirst(),tp)
end
function s.hlfilter(c)
	return c:IsSetCard(0x567) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.rescon(tc)
	return function(sg,e,tp,mg)
		for sc in aux.Next(sg) do
			sc:RegisterFlagEffect(id,0,0,0)
		end
--		Synchro.AdditionalCost=sg
		local res=not sg:IsExists(aux.NOT(s.hlfilter),1,nil)
			and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,tc)
		for sc in aux.Next(sg) do
			sc:ResetFlagEffect(id)
		end
--		Synchro.AdditionalCost=nil
		return res
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	local sg=Duel.GetMatchingGroup(s.hlfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,tc)
	if chk==0 then return aux.SelectUnselectGroup(sg,e,tp,5,5,s.rescon(tc),0) end
	local g=aux.SelectUnselectGroup(sg,e,tp,5,5,s.rescon(tc),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)   
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,tc)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.SynchroSummon(tp,sc,tc)
			tc:SetReason(REASON_MATERIAL+REASON_SYNCHRO,true)
		end
	end
end
