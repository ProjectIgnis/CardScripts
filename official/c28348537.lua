--ブリザード・プリンセス
--Blizzard Princess
local s,id=GetID()
function s.initial_effect(c)
	--summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.actlimit)
	c:RegisterEffect(e2)
end
function s.otfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsControler(tp) or c:IsFaceup())
end
function s.actlimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(0,1)
	e1:SetValue(s.elimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end