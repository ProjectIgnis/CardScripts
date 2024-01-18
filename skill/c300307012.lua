--My Precious Queen!
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_INSECT_QUEEN}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Normal Summon Level 7 monsters for 1 less Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(function(e,c) return c:IsMonster() and c:IsRace(RACE_INSECT) and c:IsLevel(7) end)
	e1:SetValue(0x1)
	Duel.RegisterEffect(e1,tp)
	--Special Summon 1 "Insect Monster Token" during End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end)
	e2:SetOperation(s.spop)
	Duel.RegisterEffect(e2,tp)
	--Can Tribute Insect monsters from hand when attacking with "Insect Queen" monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(0x5f)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_INSECT_MONSTER,0,TYPES_TOKEN,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH) then
		Duel.Hint(HINT_CARD,tp,id)
		local token=Duel.CreateToken(tp,TOKEN_INSECT_MONSTER)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		--This Token cannot be Tributed, except for the Tribute Summon of an Insect Monster
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT)))
		token:RegisterEffect(e1,true)
		--Cannot be Tributed for effect, except Insect monster's effects
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_RELEASE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTarget(function(e,c,rp,r,re) return c==token and r&(REASON_COST+REASON_EFFECT)>0 and re and not re:GetHandler():IsRace(RACE_INSECT) end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e2,true)
	end
end