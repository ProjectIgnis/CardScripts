--rankup related functions
function Auxiliary.EnableCheckRankUp(c,condition,operation,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(Auxiliary.ReincarnationCheckCondition(condition))
	if operation then
		e1:SetOperation(operation)
	end
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
		if (not monsterFilter or #monsterFilter==0) and #g>0 then e:GetLabelObject():SetLabel(1) return end
		for _,filter in ipairs(monsterFilter) do
			if type(filter)=="function" and g:IsExists(filter,1,nil) then
				e:GetLabelObject():SetLabel(1)
			elseif type(filter)=="number" then
				if g:IsExists(Card.IsSummonCode,1,nil,c,c:GetSummonType(),c:GetSummonPlayer(),filter)
					or c:GetFlagEffectLabel(511000685)==filter then
					e:GetLabelObject():SetLabel(1)
				end
			end
		end
	end
end

function Auxiliary.ReincarnationCheckCondition(condition)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetFlagEffect(511015134)>0
			or e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
			and (condition and condition(e,tp,eg,ep,ev,re,r,rp) or true)
	end
end

function Auxiliary.RankUpBaseFilter(c,sc)
	return not c:IsPreviousLocation(LOCATION_OVERLAY) and c:GetRank()<sc:GetRank()
end