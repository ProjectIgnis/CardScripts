--Card of Sanctity (Skill)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={10000020}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Draw until 6 cards if Slifer was NS this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
end
function s.filter(c,tp)
	return c:IsCode(10000020) and c:IsStatus(STATUS_SUMMON_TURN) and c:IsSummonPlayer(tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	return ct1>0 and Duel.IsPlayerCanDraw(tp,ct1) and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ht<6 then 
		Duel.Draw(tp,6-ht,REASON_EFFECT)
	end
	ht=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
	if ht<6 then 
		Duel.Draw(1-tp,6-ht,REASON_EFFECT)
	end
end