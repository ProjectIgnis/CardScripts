--デュエリスト・キングダム
--Duelist Kingdom
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.init)
end
function s.init(c)
	--no direct
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	Duel.RegisterEffect(e1,0)
	--summon face-up defense
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(1,1)
	Duel.RegisterEffect(e2,0)
	local limeff=Effect.CreateEffect(c)
	limeff:SetDescription(aux.Stringid(72497366,0))
	limeff:SetType(EFFECT_TYPE_FIELD)
	limeff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	limeff:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	limeff:SetCondition(s.ntcon)
	--summon any level
	for _,proc in ipairs({EFFECT_SET_PROC,EFFECT_SUMMON_PROC}) do
		local leff=limeff:Clone()
		leff:SetCode(proc)
		Duel.RegisterEffect(leff,0)
	end
	limeff:Reset()
	--burn for destroy
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetOperation(s.damop)
	Duel.RegisterEffect(e8,0)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local _,max=c:GetTributeRequirement()
	return max>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.damfilter(c,p)
	return c:IsPreviousControler(p) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local pg=eg:Filter(s.damfilter,nil,p)
		if #pg>0 then
			local sum=pg:GetSum(Card.GetPreviousAttackOnField)//2
			if sum>0 then
				Duel.Damage(p,sum,REASON_EFFECT)
			end
		end
	end
end
