--The Roids are Alright
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--At the start of the Duel, flip this card over
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.flipupop)
	c:RegisterEffect(e1)
end
s.listed_names={23299957} --"Vehicroid Connection Zone"
s.listed_series={SET_ROID}
function s.flipupop(e,tp,eg,ep,ev,re,r,rp)
	--Flip this card over
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local c=e:GetHandler()
	--"Vehicroid Connection Zone" can be used to Fusion Summon any "roid" monsters from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.vczop)
	Duel.RegisterEffect(e1,tp)
	--All "roid" monsters whose original Level is 6 or lower can be Normal Summoned/Set without Tributing
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetCondition(s.ntcon)
	e2:SetTarget(aux.FieldSummonProcTg(function(e,c) return c:GetOriginalLevel()<=6 and c:IsLevelAbove(5) and c:IsSetCard(SET_ROID) end))
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	Duel.RegisterEffect(e3,tp)
	--If a non-Fusion "roid" Machine monster you control whose original Level is 6 or lower attacks an opponent's monster, it gains ATK equal to its own Level x 100 during the Damage Step only
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetValue(function(e,c) return c:GetLevel()*100 end)
	Duel.RegisterEffect(e4,tp)
	--If you control a non-Machine monster, flip this card over
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetLabelObject({e1,e2,e3,e4})
	e5:SetCondition(s.flipdowncon)
	e5:SetOperation(s.flipdownop)
	Duel.RegisterEffect(e5,tp)
end
function s.vczop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,LOCATION_ALL,nil,23299957)
	for tc in g:Iter() do
		local eff=tc:GetActivateEffect()
		eff:Reset()
		tc:RegisterEffect(Fusion.CreateSummonEff(tc,s.fusfilter,nil,nil,nil,nil,s.stage2))
	end
end
function s.fusfilter(c,tp)
	return c:IsSetCard(SET_VEHICROID) or (Duel.HasFlagEffect(tp,id) and c:IsSetCard(SET_ROID))
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local c=e:GetHandler()
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3001)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Its effects cannot be negated
		local e2=e1:Clone()
		e2:SetDescription(3308)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(function(e,ct) return Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT):GetHandler()==e:GetHandler() end)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.HasFlagEffect(tp,id) and minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	local bc=Duel.GetAttackTarget()
	return Duel.HasFlagEffect(tp,id) and (Duel.IsPhase(PHASE_DAMAGE) or Duel.IsPhase(PHASE_DAMAGE_CAL)) and bc and bc:IsControler(1-tp)
end
function s.atktg(e,c)
	return c:IsSetCard(SET_ROID) and c:IsRace(RACE_MACHINE) and not c:IsType(TYPE_FUSION) and c:GetOriginalLevel()<=6
		and c:HasLevel() and Duel.GetAttacker()==c
end
function s.flipdowncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(aux.NOT(Card.IsRace),RACE_MACHINE),tp,LOCATION_MZONE,0,1,nil)
end
function s.flipdownop(e,tp,eg,ep,ev,re,r,rp)
	--Flip this card over
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	Duel.ResetFlagEffect(tp,id)
	--Reset this effect itself and all other effects that were registered when this card was flipped over
	local effs=e:GetLabelObject()
	for _,eff in ipairs(effs) do
		eff:Reset()
	end
	e:Reset()
end
