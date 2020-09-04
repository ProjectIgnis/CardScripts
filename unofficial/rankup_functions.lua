--Rank-Up related functions

FLAG_RANKUP = 511001822
EFFECT_RANKUP_EFFECT = 511001822

function Auxiliary.EnableCheckRankUp(c,condition,operation,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(Auxiliary.RankUpCheckCondition(condition,...))
	e1:SetOperation(Auxiliary.RankUpCheckOperation(operation,...))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(Auxiliary.RankUpCheckValue(...))
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end

function Auxiliary.RankUpCheckValue(...)
	local monsterFilter={...}
	return function(e,c)
		e:GetLabelObject():SetLabel(0)
		local g=c:GetMaterial():Filter(Auxiliary.RankUpBaseFilter,nil,c)
		if #g==0 then return end
		if #monsterFilter==0 and #g>0 then e:GetLabelObject():SetLabel(1) return end
		for _,filter in ipairs(monsterFilter) do
			if type(filter)=="function" and g:IsExists(filter,1,nil) then
				e:GetLabelObject():SetLabel(1) return
			elseif type(filter)=="number" then
				if g:IsExists(Card.IsSummonCode,1,nil,c,c:GetSummonType(),c:GetSummonPlayer(),filter) then
					e:GetLabelObject():SetLabel(1) return
				end
			end
		end
	end
end

function Auxiliary.RankUpCheckCondition(condition,...)
	local monsterFilter={...}
	local nameFilter={}
	for _,filter in ipairs(monsterFilter) do
		if type(filter)=="number" then
			nameFilter[filter]=true
		end
	end
	return function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():GetFlagEffect(511015134)>0 then return true end
		local flagLabels={e:GetHandler():GetFlagEffectLabel(511000685)}
		for _,flagLabel in ipairs(flagLabels) do
			if nameFilter[flagLabel] then return true end
		end
		return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
			and (not condition or condition(e,tp,eg,ep,ev,re,r,rp))
	end
end

function Auxiliary.RankUpCheckOperation(operation,...)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local rankupEffects={c:GetCardEffect(EFFECT_RANKUP_EFFECT)}
		for _,rankupEffect in ipairs(rankupEffects) do
			local te=rankupEffect:GetLabelObject():Clone()
			te:SetReset(te:GetLabel())
			c:RegisterEffect(te)
		end
		if operation then operation(e,tp,eg,ep,ev,re,r,rp) end
	end
end

function Auxiliary.RankUpBaseFilter(c,sc)
	return not c:IsPreviousLocation(LOCATION_OVERLAY) and c:GetRank()<sc:GetRank()
end

function Auxiliary.RankUpUsing(cg,id,hint)
	if type(cg)=="Group" then
		for c in aux.Next(cg) do
			c:RegisterFlagEffect(511000685,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,hint and EFFECT_FLAG_CLIENT_HINT or 0,1,id,hint)
		end
	else
		cg:RegisterFlagEffect(511000685,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,hint and EFFECT_FLAG_CLIENT_HINT or 0,1,id,hint)
	end
end

function Auxiliary.RankUpComplete(cg,hint)
	if type(cg)=="Group" then
		for c in aux.Next(cg) do
			c:RegisterFlagEffect(511015134,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,hint and EFFECT_FLAG_CLIENT_HINT or 0,1,nil,hint)
		end
	else
		cg:RegisterFlagEffect(511015134,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,hint and EFFECT_FLAG_CLIENT_HINT or 0,1,nil,hint)
	end
end
