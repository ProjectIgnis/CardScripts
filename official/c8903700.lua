--儀式魔人リリーサー
local s,id=GetID()
function s.initial_effect(c)
	--ritual material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetCondition(s.con)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--become material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.con(e)
	return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	for rc in aux.Next(eg) do
		if rc:GetFlagEffect(id)==0 then
			--cannot special summon
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetAbsoluteRange(ep,0,1)
			rc:RegisterEffect(e1,true)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
